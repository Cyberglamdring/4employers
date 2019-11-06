USER=vagrant
HOST_IP=177.122.51.1
METALLB_IP=177.122.51.240/28

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

# Kubectl autocomplete
echo "source <(kubectl completion bash)" >> ~/.bashrc

# ---- WARNING ----
# 1) On MASTER VM:
# kubeadm token list
# TOKEN                     TTL       EXPIRES                USAGES                   DESCRIPTION                                                EXTRA GROUPS
# w4q3mf.zu1yyhk5v73h4d7y   6h        2019-11-06T14:28:22Z   authentication,signing   The default bootstrap token generated by 'kubeadm init'.   system:bootstrappers:kubeadm:default-node-token
# ----
# 2) copy token
# 3) on WORKER VM:
# kubeadm join 177.122.50.1:6443 --token w4q3mf.zu1yyhk5v73h4d7y \