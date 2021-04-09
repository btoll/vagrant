#!/bin/bash

set -ex

IP=${1:-10.8.8.30}
# We're building an IP pool (a range).
# End result is:
#   - 10.8.8.30-10.8.8.40
# TODO: There should be checks for end of range, i.e. 254.
LAST_OCTET="${IP##*.}"
ADD_TEN=$(( LAST_OCTET + 10 ))
# String replacement.
IP_ADD_TEN="${IP/$LAST_OCTET/$ADD_TEN}"

# Install kube-router.
# https://github.com/cloudnativelabs/kube-router/blob/master/docs/user-guide.md
kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kube-router-all-service-daemonset.yaml

# Install MetalLB.
# https://metallb.universe.tf/installation/
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml
# On first install only.
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

# Apply config map for address pools.
# https://metallb.universe.tf/configuration/
kubectl apply -f <(cat <<-EOF
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
      - ${IP}-${IP_ADD_TEN}
EOF
)

