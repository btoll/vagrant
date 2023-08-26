#!/usr/bin/bash

set -euxo pipefail

kubeadm config images pull

# Use `--control-plane-endpoint` for HA instead of `--apiserver-advertise-address`.
# It can be the name of the control plane, which later can be swapped out for a
# load balancer.
#
# Also, the `--pod-network-cidr` value may need to match the CNI's CIDR IP pool
# range.  This can be specified in a ClusterConfiguration resource in
# `networking/podSubnet` field.
#    --apiserver-advertise-address="$CONTROL_PLANE_IP" \
#kubeadm init \
#    --control-plane-endpoint "$CONTROL_PLANE_IP" \
#    --cri-socket=unix:///var/run/crio/crio.sock \
#    --pod-network-cidr "$POD_CIDR" \
#    | tee /vagrant/kubeadm-init.out

#    --node-name $HOST_NAME \
kubeadm init \
    --apiserver-advertise-address="$CONTROL_PLANE_IP" \
    --apiserver-cert-extra-sans="$CONTROL_PLANE_IP" \
    --cri-socket=unix:///var/run/crio/crio.sock \
    --pod-network-cidr=172.16.0.0/16 \
    | tee /vagrant/kubeadm-init.out

# Note instead of capturing the output of `kubeadmin init` in the `kubeadm-init.out`
# file, we could just run the command below and send its output to a file.
# Pick your poison.
#
#       kubeadm token create --print-join-command
#
# https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-token/#options
#
# Also, `kubeadm token list`
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
#KUBECONFIG=/etc/kubernetes/admin.conf \
#    kubectl \
#    apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Install the Dashboard.
# https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
#KUBECONFIG=/etc/kubernetes/admin.conf \
#    kubectl \
#    apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

systemctl daemon-reload
systemctl restart kubelet

