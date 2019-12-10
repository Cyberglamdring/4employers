#!/bin/bash

HOST_IP=192.168.101.10

# Presettings
yum update -y
yum install -y curl policycoreutils-python openssh-server

systemctl enable sshd
systemctl start sshd


# HTTP, HTTPS and SSH access in the system firewall
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
systemctl reload firewalld

# Postfix - send notification emails
yum install postfix
systemctl enable postfix
systemctl start postfix

curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | bash

EXTERNAL_URL="$HOST_IP" yum install -y gitlab-ee