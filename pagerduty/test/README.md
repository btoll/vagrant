# Test

## Export Environment

### AWS credentials

Here's a fun Bash function that you can have for free!

```
parse_aws_creds() {
    local creds
    creds=$(< "$HOME/accessKeys.csv" tail -1)
    echo "export AWS_ACCESS_KEY_ID="$(echo $creds | awk -F, '{ print $1 }')
    echo "export AWS_SECRET_ACCESS_KEY="$(echo $creds | awk -F, '{ print $2 }')
```

> Of course, this assumes your keys to be in `$HOME/accessKeys.csv`!

To export into your environment, simply run:

```
eval $(parse_aws_creds)
```

### GitHub webook credentials

See the example in `example/env.sh.example`.

```
eval $(./env.sh)
```

## To clone private repositories

1. Ensure the `ssh-agent` host is running and seeded with the correct key.

        eval $(ssh-agent) && ssh-add

    If there's only one file then the `ssh-add` command doesn't need a file argument.

1. Must not `git clone` as the root user (so, we're doing it in `./scripts/user.sh`).
1. Add `config.ssh.forward_agent = true` to Vagrantfile.
1. Get the host's pubkey (github.com) and add it to `known_hosts`.
1. Add ssh-agent forwarding to the host's `~/.ssh/config` file for "github.com" (this appears to be optional).

```
vagrant up
```

---

## Setup

<!--
# Need to run `ngrok http 4141` to get the url and then export it to URL.
# Don't forget to add `/events` to the URL!!!!!!!!!!!!!!
# If you get a 405 error than you've forgotten to add it :)
-->

1. Open two sessions and ssh into the vagrant VM.

1. Create tunnel in first session.

```
ngrok http 4141
```

Copy https url.

1. Create webhook and start Atlantis server in second session.

```
URL={copied url from previous step}
sh /vagrant/setup.sh
```

1. Create PR and push to repo.

[webhooks]: https://docs.github.com/en/rest/reference/repos#webhooks
[events]: https://docs.github.com/en/enterprise-server/actions/learn-github-actions/events-that-trigger-workflows
[testing locally]: https://www.runatlantis.io/guide/testing-locally.html

