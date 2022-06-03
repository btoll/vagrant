https://learn.hashicorp.com/collections/vault/getting-started

```
$ vault server -dev
```

In another session:

```
$ cat > unseal.key
foso+l9S5ATbSOA2sQV+y23BqTqYNubrdTgzjDSsIsU=
$ export VAULT_TOKEN="s.HWqR3iASzRSshauQffAZqK0f"
$ export VAULT_ADDR='http://127.0.0.1:8200'
$ vault kv put secret/hello foo=world

$ vault kv get secret/hello
$ vault kv get -field foo secret/hello

$ vault kv get -format json secret/hello
$ vault kv get -format json secret/hello | jq -r .data.data.foo

$ vault kv delete secret/hello
$ vault kv destroy -versions=1,2 secret/hello # will delete and destroy both data and metadata
$ vault kv metadata delete secret/hello
```

When running Vault in dev mode, Key/Value v2 secrets engine is enabled at `secret/` path.

Enabled the `kv` secrets engine:

```
$ vault secrets enable -path=kv kv
$ vault secrets list
$ vault kv put kv/hello target=world
$ vault kv get kv/hello
$ vault kv put kv/my-secret value="s3c(eT"
$ vault kv get kv/my-secret
$ vault kv delete kv/my-secret
$ vault kv list kv/
```

The Vault server `dev` mode defaults to the following secrets engine at the `secret/` path:

```
$ vault secrets enable -path=secret kv
```

Disable the secrets engine:

```
$ vault secrets disable kv/
```

Enable the aws secrets engine:

```
$ vault secrets enable -path=aws aws
vault write aws/config/root \
    access_key=$AWS_ACCESS_KEY_ID \
    secret_key=$AWS_SECRET_ACCESS_KEY \
    region=us-east-1
```

Create a role and attach an inline policy:

```
$ vault write aws/roles/my-role \
        credential_type=iam_user \
        policy_document=-<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1426528957000",
      "Effect": "Allow",
      "Action": [
        "ec2:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
```

Create a new IAM user and generate temporary credentials:

```
$ vault read aws/creds/my-role
Key                Value
---                -----
lease_id           aws/creds/my-role/bE5ev11vE6T8wDud1QTmXJaX
lease_duration     768h
lease_renewable    true
access_key         AKIATNFRIZJOKNWOKWMI
secret_key         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
security_token     <nil>
```

Revoking the lease deletes the IAM user and invalidate the keys:

```
$ vault lease revoke aws/creds/my-role/bE5ev11vE6T8wDud1QTmXJaX
```

Getting help:

```
$ vault path-help PATH
$ vault path-help aws
$ vault path-help aws/creds/my-non-existent-role
```

Token is the core authentication method.

```
$ vault token create
Key                  Value
---                  -----
token                s.z65GT3KB8RADkmsb5FfcWvD7
token_accessor       tBR8TNF4C6CFYsh2t0ydyl7Y
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
$
$ vault login s.z65GT3KB8RADkmsb5FfcWvD7
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                s.z65GT3KB8RADkmsb5FfcWvD7
token_accessor       tBR8TNF4C6CFYsh2t0ydyl7Y
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
$
$ vault token revoke s.z65GT3KB8RADkmsb5FfcWvD7
```

Enable GitHub auth method:

```
$ vault auth enable github
```

Set the organization for the GitHub authentication.

```
$ vault write auth/github/config organization=hashicorp
```

Configure the GitHub engineering team authentication to be granted the default and applications policies.

```
$ vault write auth/github/map/teams/engineering value=default,applications
```

```
$ vault auth list
$ vault auth help github
$
$ vault login -method=github
$ vault token revoke -mode path auth/github
$
$ vault auth disable github
```

View default policy:

```
$ vault policy read default
```

```
$ vault policy write -h
$ vault policy write my-policy - << EOF
# Dev servers have version 2 of KV secrets engine mounted by default, so will
# need these paths to grant permissions:
path "secret/data/\*" {
  capabilities = ["create", "update"]
}

path "secret/data/foo" {
  capabilities = ["read"]
}
EOF
$
$ vault policy list
default
my-policy
root
$ vault policy read my-policy
$
$ export VAULT_TOKEN="$(vault token create -field token -policy=my-policy)"
$ vault token lookup | ag policies
$
$ vault kv put secret/creds password="my-long-password"
```

Approles

```
$ vault auth enable approle
$ vault write auth/approle/role/my-role \
    secret_id_ttl=10m \
    token_num_uses=10 \
    token_ttl=20m \
    token_max_ttl=30m \
    secret_id_num_uses=40 \
    token_policies=my-policy
$ export SECRET_ID="$(vault write -f -field=secret_id auth/approle/role/my-role/secret-id)"
$ vault write auth/approle/login role_id="$ROLE_ID" secret_id="$SECRET_ID"
```

Secrets engines:
- store secrets
- generate secrets
- encrypt data

Different types of secrets engines:
- aws
- consul
- database
- active directory
- pki
- ssh

Lifecycle:
- enable
    + `vault secrets enable [options] TYPE`
- disable
    + `vault secrets disable [options] PATH`
- move (to a different path)
    + `vault secrets move [options] SOURCE_PATH DESTINATION_PATH`
- tune
    + `vault secrets tune [options] PATH`

