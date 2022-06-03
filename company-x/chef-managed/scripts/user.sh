#!/usr/bin/env bash
# shellcheck disable=2016

set -euo pipefail

mkdir -p "$HOME/.aws"
cat << EOF > "$HOME/.aws/credentials"
[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
EOF

#cat << EOF > "$HOME/.aws/config"
#[okta]
#aws_saml_url = home/amazon_aws/0oa1f26d64tYiXTl90h8/272
#mfa_provider = DUO
#mfa_factor_type = web
#
#[profile taos]
#role_arn = arn:aws:iam::622089341825:role/taos-engineer
#
#[profile taos-ro]
#role_arn = arn:aws:iam::622089341825:role/read-only
#EOF

cat << EOF > "$HOME/.aws/config"
[default]
region = us-west-1
EOF

{
    echo 'eval "$(chef shell-init bash)"' ;
    echo "export GIT_HOST=$GIT_HOST" ;
    echo "export GITHUB_TOKEN=$GITHUB_TOKEN" ;

    echo "export TARGET_USER=$TARGET_USER" ;
    echo "export TARGET_REPO=$TARGET_REPO" ;

    # Fixes error when `region` isn't provided in the `aws` provider.
    echo "export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" ;
    echo "export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" ;
    echo "export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" ;
    # For `aws-okta`.
    echo "export AWS_OKTA_MFA_DUO_DEVICE=token" ;

    echo "export JFROG_USERNAME=$JFROG_USERNAME" ;
    echo "export JFROG_PASSWORD=$JFROG_PASSWORD" ;

    echo "export REPO_ALLOWLIST=$REPO_ALLOWLIST" ;

    echo "export ARTIFACTORY_REGISTRY_USER=$JFROG_USERNAME" ;
    echo "export ARTIFACTORY_API_KEY=$JFROG_PASSWORD" ;

    echo "export CHEF_REPO=$CHEF_REPO" ;
    echo "export CHEF_BRANCH=$CHEF_BRANCH" ;

    # `/usr/bin` contains all the Chef Workstation binaries, else it will default to the `asdf` shims.
    echo "export PATH=/usr/bin:$PATH" ;
} >> "$HOME/.bashrc"

exit






##################################
########## HOUSEKEEPING ##########
##################################

cp -r /vagrant/setup_atlantis.sh .

pushd "$HOME/pagerduty/chef"
# Get knife config and cert in `/vagrant/.chef`.
cp -r /vagrant/.chef .

# Get the cookbooks from the public supermarket to avoid needing credentials (currently getting an Unauthorized error).
sed -i "s/source artifactory.*/source \'https:\/\/supermarket.chef.io\'/g" Berksfile

# The following should be run on the chef client ec2 instance.
cat << EOF > runlist.json
{
    "run_list": [
	"role[twistlock-btoll]"
    ]
}
EOF
popd

exit

# NOTE that vagrant runs have been failing here.  When that happens,
# do the following before continuing with the commands below:
#cd "$HOME/pagerduty/chef"
#gem install bundler:2.2.17
# It has then worked for me (don't yet know why).

# Install community cookbooks to default location `$HOME/.berkshelf`.
set +e
gem install bundler:2.2.17
berks install
set -e
# Will add the contents of the tarball to `./cookbooks/`.
tar xzf /vagrant/pd-cookbooks.tgz -C "$HOME/.berkshelf"

# First delete any existing cookbooks?
#knife cookbook bulk delete "^.*$" --purge --yes

# Upload to Managed Chef Infra Server... (order matters!)
# Upload community cookbooks.
berks upload
# Upload PD cookbooks.
knife cookbook upload --all -o cookbooks:site-cookbooks

# Upload all data bags.
#knife upload data_bags

chef-client \
    -c .chef/config.rb \
    -j runlist.json \
    --chef-license accept-silent
popd

