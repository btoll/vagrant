#!/usr/bin/env bash
# shellcheck disable=2016

set -euo pipefail

# This is necessary to access the private repos (see README).
ssh-keyscan -H github.com >> .ssh/known_hosts

mkdir pagerduty
pushd pagerduty

REPOS=(
#    chef.git
    pd-btoll-test.git
#    pd-btoll-upgrade.git
#    terraform-aws-autoscaling-group.git
#    terraform-common.git
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
git config --global url."ssh://git@github.com/".insteadOf https://github.com/
# For creating cookbooks.
git config --global user.email "$CHEF_GITHUB_EMAIL"
git config --global user.name "$CHEF_GITHUB_USER"

# Let's create a test cookbook!
#chef generate cookbook cookbooks/foo --chef-license accept-silent

mkdir -p "$HOME/.aws"
cat << EOF > "$HOME/.aws/credentials"
[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
EOF

cat << EOF > "$HOME/.aws/config"
[okta]
aws_saml_url = home/amazon_aws/0oa1f26d64tYiXTl90h8/272
mfa_provider = DUO
mfa_factor_type = web

[profile taos]
role_arn = arn:aws:iam::622089341825:role/taos-engineer

[profile taos-ro]
role_arn = arn:aws:iam::622089341825:role/read-only
EOF

{
    echo 'eval "$(chef shell-init bash)"' ;
    echo "export GITHUB_TOKEN=$GITHUB_TOKEN" ;
    echo "export GIT_HOST=$GIT_HOST" ;
    echo "export GITHUB_USER=$GITHUB_USER" ;
    echo "export GITHUB_REPO=$GITHUB_REPO" ;
    echo "export REPO_ALLOWLIST=$REPO_ALLOWLIST" ;
    # Fixes error when `region` isn't provided in the `aws` provider.
    echo "export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" ;
    # For `aws-okta`.
    echo "export AWS_OKTA_MFA_DUO_DEVICE=token" ;
} >> "$HOME/.bashrc"

cp /vagrant/{setup.sh,chef-solo.tgz,solo.rb,web.json} .

