# Managed Chef

## Seed Environment

```
eval $(ssh-agent) && ssh-add
eval $(./env.sh)
eval $(parse_aws_creds btoll-general)
eval $(parse_jfrog_creds)
```

## TODO

- cloud-init

