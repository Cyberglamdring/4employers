USER=vagrant
HOST_IP=192.168.100.51
METALLB_IP=192.168.100.240/28

# Add k8s repository
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Set SELinux in permissive mode (effectively disabling it)
# For access of containers to the host file system
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Install k8s
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet

# Disable SELinux
getenforce | grep Disabled || setenforce 0
echo "SELINUX=disabled" > /etc/sysconfig/selinux

# Disable SWAP
sed -i '/swap/d' /etc/fstab
swapoff --all

# Use common driver
touch /etc/docker/daemon.json
cat <<EOF > /etc/docker/daemon.json
{
  "exec-opts": [
    "native.cgroupdriver=systemd"
  ]
}
EOF

cat <<EOF > /etc/sysctl.d/docker.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

systemctl restart docker

# Vagrant kubelet fix
sed -i "s/\(KUBELET_EXTRA_ARGS=\).*/\1--node-ip=$HOST_IP/" /etc/sysconfig/kubelet

kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --apiserver-advertise-address $HOST_IP

# kubeadm join 177.122.1.50:6443 --token w4q3mf.zu1yyhk5v73h4d7y \
#     --discovery-token-ca-cert-hash sha256:a81970e3691b2b76b8f1f5c257352cd23420a534d8952fde9dda984e31f23e44

# ROOT kubectl
mkdir /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
# Kubectl autocomplete
echo "source <(kubectl completion bash)" >> ~/.bashrc

# USER kubectl
mkdir /home/$USER/.kube
cp /etc/kubernetes/admin.conf /home/$USER/.kube/config
chown $USER:$USER /home/$USER/.kube/config
# Kubectl autocomplete
echo "source <(kubectl completion bash)" >> /home/$USER/.bashrc

# Deploy POD's network
# Flannel - Software Defined Network, SDN
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl patch daemonsets kube-flannel-ds-amd64 -n kube-system --patch='{
  "spec":{
    "template":{
      "spec":{
        "containers":[
          {
            "name": "kube-flannel",
            "args":[
              "--ip-masq",
              "--kube-subnet-mgr",
              "--iface=eth1"
            ]
          }
        ]
      }
    }
  }
}'
# kubectl get pods -n kube-system

# Load-balancer MetalLB
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.3/manifests/metallb.yaml
# Configmap for MetalLB
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - $METALLB_IP
EOF
# kubectl get pods -n metallb-system

# Configurate NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/service-nodeport.yaml

kubectl patch -n ingress-nginx svc ingress-nginx --patch '{"spec": {"type": "LoadBalancer"}}'
# kubectl cluster-info

# Disbled master node protection
kubectl taint nodes --all node-role.kubernetes.io/master-

