#!/bin/bash
yum install -y epel-release
yum -y update
yum install -y net-tools htop mc git
yum install -y yum-utils \
device-mapper-persistent-data \
lvm2
yum-config-manager \
--add-repo \
https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
yum clean all

systemctl enable docker
systemctl start docker

# SSH FIX
# WARNING: reboot required
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
