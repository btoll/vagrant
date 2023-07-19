#!/usr/bin/bash
# shellcheck disable=2091

set -euxo pipefail

# Extract and execute the kubeadm join command from the exported file.
# https://catonmat.net/sed-one-liners-explained-part-one
#$(grep --after-context 2 "kubeadm join" /vagrant/kubeadm-init.out | sed -e :a -e '/\\$/N; s/\\\n//; ta')
#
# If `kubeadm init` was configured to be high availability by using the
# `--control-plane-endpoint` option instead of the `--apiserver-advertise-address`
# option, then the logs captured in `kubeadm-init.out` will have two `kubeadm join`
# statements at the end of the log, the first for other control plane nodes and the
# second for the worker nodes.
#
# In these cases (and the initial case, frankly), we **should** be able to get the
# last two lines of the file, although clearly this is more fragile than grepping.
$(tail -2 /vagrant/kubeadm-init.out | sed -e :a -e '/\\$/N; s/\\\n//; ta')

mkdir /home/vagrant/.kube
cp /vagrant/.kube/config /home/vagrant/.kube/
chown vagrant:vagrant /home/vagrant/.kube/config

# TODO
#kubectl label node $(hostname -s) node-role.kubernetes.io/worker=worker

