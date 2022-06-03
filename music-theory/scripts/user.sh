#!/usr/bin/env bash

set -euo pipefail

ssh-keyscan -H github.com >> .ssh/known_hosts

git clone git@github.com:btoll/music-theory
cd music-theory
#npm install --save-dev @babel/core @babel/cli
npm install
npm run build

#sudo python3 -m http.server 80 &

