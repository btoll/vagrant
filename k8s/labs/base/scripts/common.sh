#!/bin/bash

# https://www.shellcheck.net/wiki/SC1091
# shellcheck source=/dev/null

set -euxo pipefail

umask 0022

# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#forwarding-ipv4-and-letting-iptables-see-bridged-traffic
# `br_netfilter` is required to enable transparent masquerading and to facilitate
# Virtual Extensible LAN (VxLAN) traffic for communication between Kubernetes pods
# across the cluster.
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot (make sure kernel is aware of changes).
sysctl --system

apt-get update && \
apt-get install -y \
    curl \
    gpg

# Install cri-o.
# https://github.com/cri-o/cri-o/blob/main/install.md#apt-based-operating-systems
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cri-o
# cri-o uses the `systemd` cgroup driver by default.

####################################################
# I downloaded the keys because I kept getting 404s.
# "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key"
# "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/Release.key"
####################################################

echo \
    "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] \
    https://mirrorcache-us.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" \
    > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list

echo \
    "deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] \
    https://mirrorcache-us.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" \
    > "/etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list"

mkdir -p /usr/share/keyrings
gpg \
    --dearmor \
    -o /usr/share/keyrings/libcontainers-archive-keyring.gpg /vagrant/keys/libcontainers-archive-keyring.key
gpg \
    --dearmor \
    -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg /vagrant/keys/libcontainers-crio-archive-keyring.key

apt-get update && \
apt-get install -y \
    cri-o \
    cri-o-runc

systemctl daemon-reload
systemctl enable crio --now

############################################################
############################################################

# Install Kubernetes binaries.
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
# ----------------------------
# Update the apt package index and install packages needed to use the Kubernetes
# apt repository.
apt-get update && \
apt-get install -y \
    apt-transport-https \
    ca-certificates

# Download the Google Cloud public signing key.
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg \
  https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Add the Kubernetes apt repository.
#  "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] \
echo \
  "deb [trusted=yes] \
  https://apt.kubernetes.io/ kubernetes-xenial main" \
  | tee /etc/apt/sources.list.d/kubernetes.list
cp /vagrant/keys/kubernetes-archive-keyring.gpg /usr/share/keyrings/

# Update apt package index, install kubelet, kubeadm and kubectl, and pin their version.
apt-get update && \
apt-get install -y \
    kubeadm \
    kubectl \
    kubelet && \
apt-mark hold \
    kubelet \
    kubeadm \
    kubectl

# Each node in the cluster needs the following file and k/v pair.  Without it, we'll get the
# following error:
#
#   error: error upgrading connection: unable to upgrade connection: pod does not exist
#
# https://github.com/kubernetes/kubernetes/issues/63702#issuecomment-474948254
echo "KUBELET_EXTRA_ARGS=--node-ip=$NODE_IP" > /etc/default/kubelet

# This sets up `kubectl` autocompletion.
tee -a /home/vagrant/.bashrc << EOF
# https://kubernetes.io/docs/reference/kubectl/cheatsheet/#bash
if command -v kubectl > /dev/null
then
    source <(kubectl completion bash)
    alias k="kubectl"
    complete -o default -F __start_kubectl k
fi
EOF

# TODO:
# - augment /etc/hosts for every worker node
#
# Adding the control plane hostname for every node at least allows
# for a HA cluster once if a load balancer is ever placed in front
# of the control plane(s).
echo "$CONTROL_PLANE_IP $CONTROL_PLANE_NAME" >> /etc/hosts

