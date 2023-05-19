#!/usr/bin/bash

set -euxo pipefail

kubeadm config images pull

kubeadm init --pod-network-cidr "$POD_CIDR" --apiserver-advertise-address "$API_ADV_ADDRESS" --cri-socket=unix:///var/run/crio/crio.sock | tee /vagrant/kubeadm-init.out

# Note instead of capturing the output of `kubeadmin init` in the `kubeadm-init.out`
# file, we could just run the command below and send its output to a file.
# Pick your poison.
#
#       kubeadm token create --print-join-command
#
# https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-token/#options

mkdir /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config

mkdir -p /vagrant/.kube
cp /etc/kubernetes/admin.conf /vagrant/.kube/config

# `kube-router` CNI.
#KUBECONFIG=/etc/kubernetes/admin.conf \
#    kubectl \
#    apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter.yaml

# `calico` CNI.
KUBECONFIG=/etc/kubernetes/admin.conf \
    kubectl \
    apply -f "https://raw.githubusercontent.com/projectcalico/calico/v$CALICO_VERSION/manifests/calico.yaml"

# Install the metrics server.
# https://github.com/kubernetes-sigs/metrics-server
KUBECONFIG=/etc/kubernetes/admin.conf \
    kubectl \
    apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Install the Dashboard.
# https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
KUBECONFIG=/etc/kubernetes/admin.conf \
    kubectl \
    apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

systemctl daemon-reload
systemctl restart kubelet

