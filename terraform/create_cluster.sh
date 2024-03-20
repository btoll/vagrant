#!/bin/bash

set -euo pipefail

LANG=C
umask 0022

# aws configure list-profiles

# https://docs.aws.amazon.com/cli/latest/reference/ec2/create-vpc.html
aws ec2 create-vpc \
    --profile ilovedevopsnot-admin \
    --cidr-block 10.0.0.0/16 \
    --region us-east-1 \

# eksctl create cluster --name dev --version 1.21 --region us-east-1 --nodegroup-name standard-workers --node-type t3.micro --nodes 3 --nodes-min 1 --nodes-max 4 --managed

