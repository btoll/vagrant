#!/bin/bash

set -euo pipefail

LANG=C
umask 0022

# Configure TLS.
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout node_exporter.key \
    -out node_exporter.crt -subj "/C=US/ST=Massachusetts/L=Boston/O=derp/CN=localhost" \
    -addext "subjectAltName = DNS:localhost"

cat << EOF > config.yml
tls_server_config:
  cert_file: node_exporter.crt
  key_file: node_exporter.key
EOF

