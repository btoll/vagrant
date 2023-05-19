#!/usr/bin/bash
# shellcheck disable=2091

set -euxo pipefail

# Extract and execute the kubeadm join command from the exported file.
# https://catonmat.net/sed-one-liners-explained-part-one
$(grep --after-context 2 "kubeadm join" /vagrant/kubeadm-init.out | sed -e :a -e '/\\$/N; s/\\\n//; ta')

mkdir /home/vagrant/.kube
cp /vagrant/.kube/config /home/vagrant/.kube/
chown vagrant:vagrant /home/vagrant/.kube/config

# TODO
#kubectl label node $(hostname -s) node-role.kubernetes.io/worker=worker

