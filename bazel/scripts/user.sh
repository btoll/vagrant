#!/usr/bin/env bash

set -euo pipefail

# Download Bazelisk (a wrapper around Bazel) and its SHA.
wget https://github.com/bazelbuild/bazel/releases/download/4.2.1/bazel-4.2.1-installer-linux-x86_64.sh{,.sha256}

# Ensure no bytes were fiddled with in-transit.
# Turn on debugging for just this comparison.
set -x
[ "$(sha256sum bazel-4.2.1-installer-linux-x86_64.sh | cut -d\  -f1)" = "$(< bazel-4.2.1-installer-linux-x86_64.sh.sha256 cut -d\  -f1)" ]
set +x

chmod 755 bazel-4.2.1-installer-linux-x86_64.sh
./bazel-4.2.1-installer-linux-x86_64.sh --user

# For go.
{
    echo "export GOPATH=$HOME/go" ;
    echo "export GOROOT=/usr/local/go" ;
} >> "$HOME/.bashrc"

