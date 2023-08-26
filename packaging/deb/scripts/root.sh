#!/bin/bash

set -euo pipefail

apt-get update && \
apt-get install -y \
    avahi-utils \
    build-essential \
    devscripts \
    git \
    git-buildpackage \
    gnupg2 \
    quilt \
    reprepro \
    sbuild \
    vim

