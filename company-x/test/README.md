# Test

## Export Environment

### AWS Credentials

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

### GitHub Webhook Credentials

See the example in `example/env.sh.example`.

```
eval $(./env.sh)
```

## Add SSH Key to Agent

This enables the cloning of private repositories.

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

> Always seed the `ssh-agent` before SSHing into the VM!

---

## Setup

<!--
# Need to run `ngrok http 4141` to get the url and then export it to URL.
# Don't forget to add `/events` to the URL!!!!!!!!!!!!!!
# If you get a 405 error than you've forgotten to add it :)
-->

1. Open two sessions and ssh into the vagrant VM.

2. Create tunnel in first session.

```
ngrok http 4141
```

Copy https url.

3. Create webhook and start Atlantis server in second session.

Copy the url from previous step.  For example:

```
URL=https://1c96-47-14-76-231.ngrok.io "$HOME/setup.sh"
```

> You'll get a `502 Bad Gateway` error when first creating the webhook.  This is a known issue, don't worry about it :)  It will work when a pull request is pushed to GitHub.

4. Create PR and push to repo.

## Troubleshooting

- If you get the following error when pushing to GitHub, make sure that the session in which you ran `./setup.sh` to create the webhook and to start the atlantis server has access to the SSH key in the agent:

```
Error: Failed to download module

Could not download module "vpc" (main.tf:44) source code from
"git::https://github.com/terraform-aws-modules/terraform-aws-vpc?ref=v3.7.0":
error downloading
'https://github.com/terraform-aws-modules/terraform-aws-vpc?ref=v3.7.0':
/usr/bin/git exited with 128: Cloning into '.terraform/modules/vpc'...
git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
```

The solution is to always make sure that the `ssh-agent` is properly seeded before SSHing into the VM.

- If you get 405 errors from GitHub

Make sure you've added "/events" to the URL for the GitHub webhook!  This is done automatically for you, but if you've futzed with the shell code than this could become an issue.

## `aws-okta` commands

It takes the form of:

```
aws-okta exec PROFILE -- COMMAND
```

Examples:

```
aws-okta exec taos -- aws sts get-caller-identity

aws-okta exec <profile> -- aws s3api list-buckets

aws-okta exec taos -- terraform apply
```

[webhooks]: https://docs.github.com/en/rest/reference/repos#webhooks
[events]: https://docs.github.com/en/enterprise-server/actions/learn-github-actions/events-that-trigger-workflows
[testing locally]: https://www.runatlantis.io/guide/testing-locally.html

