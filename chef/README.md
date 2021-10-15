# Chef

Uses the `ubuntu/focal64` Vagrant box.

Installs:

- Chef Workstation
- Terraform
- AWS CLI

## Hosted Chef

This installation relies upon a [Hosted Chef] environment, which means that you don't have to worry about hosting a Chef Infra server yourself.  However, an account must be first created.  For the purposes of this exercise, it is **highly** recommended that the user name is the same as an active user name on GitHub.

Once that is done, do the following steps:

- Create an organization in the UI
    + This organization name will then need to be added to the environment when the vagrant process is initiated.
- Download the [Starter Kit]
- Move it to the Vagrant project directory, ex., `mv $HOME/Downloads/chef-starter.zip .`
    + Assumes you're currently in the root project directory, i.e., the directory that contains the `Vagrantfile`.

Then, when bootstrapping the VM, the scripts will copy the `chef-starter.zip` archive from `/vagrant` to `$HOME` in the VM and `unzip` it.

> The Chef Workstation installation also includes the [`chef-solo`] binary for those who want a simpler environment, i.e., no Chef Infra server (hosted or otherwise).

## Run Vagrant

The following environment variables can be defined for the Vagrant process:

- `CHEF_ORG`
    + The name of the organization that was created above.

- `CHEF_GITHUB_EMAIL`
    + This is used for registering the values with Git, which is needed when creating cookbooks, for example.
    + Defaults to `CHEF_GITHUB_USER@example.com`.

- `CHEF_GITHUB_USER`
    + This is used for registering the values with Git, which is needed when creating cookbooks, for example.
    + Defaults to `CHEF_USER`.

- `CHEF_USER`
    + Should be the user name of the Hosted Chef account.
    + Defaults to `USER`, which probably is not what you want.

```
export CHEF_GITHUB_EMAIL=kilgore-trout@example.com
export CHEF_GITHUB_USER=kilgore-trout
export CHEF_ORG=timequake
export CHEF_USER=kilgore-trout
vagrant up
```

or

```
CHEF_GITHUB_email=kilgore-trout@example.com \
CHEF_GITHUB_USER=kilgore-trout \
CHEF_ORG=timequake \
CHEF_USER=kilgore-trout \
vagrant up
```

## Create Cookbooks

```
cd chef-repo
chef generate cookbook cookbooks/derp
```

[Hosted Chef]: https://manage.chef.io/login
[Starter Kit]: https://docs.chef.io/workstation/getting_started/
[`chef-solo`]: https://docs.chef.io/chef_solo/

