#!/usr/bin/env bash
# shellcheck disable=2016

set -euo pipefail

# This is necessary to access the private repos (see README).
ssh-keyscan -H github.com >> .ssh/known_hosts

mkdir pagerduty
pushd pagerduty

REPOS=(
    terraform-aws-autoscaling-group.git
    terraform-common.git
    pd-btoll-upgrade.git
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
    echo "export SECRET=$SECRET" ;
    echo "export GITHUB_TOKEN=$GITHUB_TOKEN" ;
    echo "export GIT_HOST=$GIT_HOST" ;
    echo "export GITHUB_USERNAME=$GITHUB_USERNAME" ;
    echo "export GITHUB_REPO=$GITHUB_REPO" ;
    echo "export REPO_ALLOWLIST=$REPO_ALLOWLIST" ;
} >> "$HOME/.bashrc"

