# PD Billing service

### To clone private repositories

1. Ensure the `ssh-agent` host is running and seeded with the correct key.

        eval $(ssh-agent) && ssh-add

    If there's only one file then the `ssh-add` command doesn't need a file argument.

1. Must not `git clone` as the root user (so, we're doing it in `./scripts/user.sh`).
1. Add `config.ssh.forward_agent = true` to Vagrantfile.
1. Get the host's pubkey (github.com) and add it to `known_hosts`.
1. Add ssh-agent forwarding to the host's `~/.ssh/config` file for "github.com" (this appears to be optional).

### Export env vars into calling environment for authentication to download gems from jfrog artifactory

```
export JFROG_USERNAME=kilgore-trout
export JFROG_PASSWORD=your-api-key
vagrant up
```

or

```
JFROG_USERNAME=kilgore-trout JFROG_PASSWORD=your-api-key \
    vagrant up
```

### Log into VM and setup database and start rails

```
bundle exec rake db:setup
bundle exec rails server -b 0.0.0.0     # To access from host machine, bind on all interfaces.
```

### Open in browser

open localhost:3000

### Test `/status` endpoint

curl localhost:3000/status

### TODO

- Automate the manual steps.
- Use Ansible for provisioning.

