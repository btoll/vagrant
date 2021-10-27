#!/usr/bin/env bash
# shellcheck disable=2016

set -euo pipefail

# This is necessary to access the private repos (see README).
ssh-keyscan -H github.com >> .ssh/known_hosts

mkdir pagerduty
pushd pagerduty

REPOS=(
    chef.git
    pd-btoll-upgrade.git
    terraform-aws-autoscaling-group.git
    terraform-common.git
)

for repo in "${REPOS[@]}"
do
    if [ ! -d "$repo" ]
    then
        git clone "git@github.com:PagerDuty/$repo"
    fi
done

popd

# GitHub no longer supports account password authentication, which we don't want to do
# anyway.  Since, we've already enabled SSH agent forwarding, use the `insteadOf` key
# in the global git config.
# https://github.blog/2020-12-15-token-authentication-requirements-for-git-operations/
cat << EOF > "$HOME/.gitconfig"
[url "ssh://git@github.com/"]
    insteadOf = https://github.com/
EOF

mkdir -p "$HOME/.aws"
cat << EOF > "$HOME/.aws/credentials"
[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
EOF

{
    echo 'eval "$(chef shell-init bash)"' ;
    echo "export GITHUB_TOKEN=$GITHUB_TOKEN" ;
    echo "export GIT_HOST=$GIT_HOST" ;
    echo "export GITHUB_USER=$GITHUB_USER" ;
    echo "export GITHUB_REPO=$GITHUB_REPO" ;
    echo "export REPO_ALLOWLIST=$REPO_ALLOWLIST" ;
    # Fixes error when `region` isn't provided in the `aws` provider.
    echo "export AWS_DEFAULT_REGION=us-west-1" ;
} >> "$HOME/.bashrc"

cp /vagrant/setup.sh .

