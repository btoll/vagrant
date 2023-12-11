#!/bin/bash

set -euo pipefail

LANG=C
umask 0022

minikube start --profile dc1 --memory 4096 --kubernetes-version=v1.28.0

helm repo add hashicorp https://helm.releases.hashicorp.com
helm install --values /vagrant/values.yaml consul hashicorp/consul --create-namespace --namespace consul --version "1.0.0"

#kubectl port-forward svc/consul-ui --namespace consul 8501:443
#consul catalog services
#consul members

#cat > counting.yaml
#cat > dashboard.yaml
kubectl apply -f /vagrant/counting.yaml && \
    kubectl apply -f /vagrant/dashboard.yaml && \
    kubectl apply -f /vagrant/intentsions.yaml

