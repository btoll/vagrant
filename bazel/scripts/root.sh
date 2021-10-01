#!/usr/bin/env bash

set -euo pipefail

apt-get update
apt-get install g++ python3-distutils unzip zip -y

# Download Go.
wget https://golang.org/dl/go1.17.1.linux-amd64.tar.gz -O - | tar -xz -C /usr/local/
install -m 0755 /usr/local/go/bin/* /usr/local/bin

# Create a `python` simlink so scripts with `/usr/bin/env python` will work correctly.
ln -s /usr/bin/python{3,}

su -c "source /vagrant/scripts/user.sh" vagrant

