#!/bin/bash

set -exo pipefail

aws ec2 create-key-pair \
    --key-name eks \
    --key-type rsa \
    --key-format pem \
    --query "KeyMaterial" \
    --output text > eks.pem

# Create cluster.
eksctl create cluster \
    --name=cloudacademy-k8s \
    --region=us-west-2 \
    --ssh-public-key=key.pem \
    --nodes=4 \
    --node-type=m5.large

aws iam get-user

# This stack names will be different, these are just examples.
# The first is the control plane.
aws cloudformation describe-stack-resources \
    --stack-name=eksctl-cloudacademy-k8s-cluster \
    --region=us-west-2

# These are the worker nodes.
aws cloudformation describe-stack-resources \
    --stack-name=eksctl-cloudacademy-k8s-nodegroup-ng-fedd1500 \
    --region=us-west-2

# Teardown.
kubectl delete svc --all
eksctl delete cluster cloudacademy-k8s --region=us-west-2

