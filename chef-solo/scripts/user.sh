#!/usr/bin/env bash
# shellcheck disable=2016

set -euo pipefail

# This is necessary to access the private repos (see README).
ssh-keyscan -H github.com >> .ssh/known_hosts

REPOS=(
    pagerduty/pd-btoll-test
)

GIT_PLATFORM=git@github.com

for repo in "${REPOS[@]}"
do
    if [ ! -d "$repo" ]
    then
        git clone "$GIT_PLATFORM:$repo" "$repo"
    fi
done

git clone --branch "$CHEF_BRANCH" "$GIT_PLATFORM:$CHEF_REPO" chef

# GitHub no longer supports account password authentication, which we don't want to do
# anyway.  Since, we've already enabled SSH agent forwarding, use the `insteadOf` key
# in the global git config.
# https://github.blog/2020-12-15-token-authentication-requirements-for-git-operations/
git config --global url."ssh://git@github.com/".insteadOf https://github.com/
# For creating cookbooks.
git config --global user.email "$CHEF_GITHUB_EMAIL"
git config --global user.name "$CHEF_GITHUB_USER"

#recipe_url "http://localhost/chef-solo.tgz"
cat << EOF > "$HOME/solo.rb"
cookbook_path [
    "/home/vagrant/chef/cookbooks",
    "/home/vagrant/chef/site-cookbooks",
    "/home/vagrant/chef/cookbooks-forked-frozen",
    "/home/vagrant/.berkshelf/cookbooks"
    ]
data_bag_path "/var/chef-solo/data_bags"
file_cache_path "/home/vagrant/cache"

EOF

cat << EOF > "$HOME/web.json"
{
    "run_list": [ "recipe[pd-twistlock]" ]
}

EOF

if [ ! -d "$HOME/.asdf" ]
then
    # http://asdf-vm.com/guide/getting-started.html
    #
    # `advice.detachedHead=false` prevents the following warning(s) in `vagrant up` stdout:
    #
    #       default: You are in 'detached HEAD' state. You can look around, make experimental
    #       default: changes and commit them, and you can discard any commits you make in this
    #       default: state without impacting any branches by switching back to a branch.
    #       ...
    #
    git clone -c advice.detachedHead=false https://github.com/asdf-vm/asdf.git .asdf --branch v0.8.1

    # For `asdf`, `gem`, `bundle`, et al
    PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"

    (
        echo ". $HOME/.asdf/asdf.sh" ;
        echo ". $HOME/.asdf/completions/asdf.bash" ;
    ) >> .bashrc

    pushd "$HOME/chef"
    asdf plugin-add ruby
    asdf plugin-add terraform
    asdf install
    gem install bundler:2.2.17
    bundle config set --global pagerduty.jfrog.io "$JFROG_USERNAME:$JFROG_PASSWORD"
    bundle update --bundler
    bundle install
    popd
fi

{
    echo 'eval "$(chef shell-init bash)"' ;
    echo "export GITHUB_TOKEN=$GITHUB_TOKEN" ;
    echo "export GIT_HOST=$GIT_HOST" ;
    echo "export GITHUB_USER=$GITHUB_USER" ;
    echo "export GITHUB_REPO=$GITHUB_REPO" ;

    # Fixes error when `region` isn't provided in the `aws` provider.
    echo "export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" ;

    echo "export JFROG_USERNAME=$JFROG_USERNAME" ;
    echo "export JFROG_PASSWORD=$JFROG_PASSWORD" ;
    echo "export ARTIFACTORY_REGISTRY_USER=$JFROG_USERNAME" ;
    echo "export ARTIFACTORY_API_KEY==$JFROG_PASSWORD" ;

    # `/usr/bin` contains all the Chef Workstation binaries, else it will default to the `asdf` shims.
    echo "export PATH=/usr/bin:$PATH" ;
} >> "$HOME/.bashrc"

pushd "$HOME/chef"
cp /vagrant/.chef .
sed -i "s/source artifactory.*/source \'https:\/\/supermarket.chef.io\'/g" Berksfile
set +e
berks install
set -e
tar xzf /vagrant/pd-cookbooks.tgz -C "$HOME/.berkshelf"
popd
chef-solo -c 

#ls -I mv_dirs.sh > mv_dirs.sh
#vim +1 mv_dirs.sh -c "let @z=\"EF-y0A \<Esc>pImv \<Esc>j\" | argdo normal 100@z" -c "argdo :x"
#chmod 700 mv_dirs.sh
#./mv_dirs.sh

