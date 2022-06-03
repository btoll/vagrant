# Managed Chef Tool

## The Problem

The current situation for testing in staging isn't great and needs some improvement.  The following are the main issues:

- [Determinism](#determinism)
- [Trust](#trust)
- [Idleness](#idleness)

Let's look at each of these in turn.

---

### Determinism

One of the strengths of testing environments is the ability to predict the state of the environment.  In addition, the surety of being able to reproduce the same state every time is not only desirable but fundamental to testing in any kind of sandboxed environment.

In other words, if the global state of the environment can be changed by outside actors, that is a big problem.

### Trust

This issue is twofold.  As we've just seen, we can't trust an environment that isn't predictable and under our control.  But in addition, there is a human element to this, as well.

For example, we're inherently trusting that everyone involved is a good actor and will play by the rules.  The locking mechanism is a good example of this.  Interestingly, we trust this non-binding feature in different ways.

- There is trust that one will wait for the lock instead of going rogue and merging the code untested.
- There is trust that one won't monopolize the lock for long periods of time and will be considerate of their teammates.
- There is trust that one won't steal the lock from an individual who has played by the rules and has waited for the lock.  If that does happen, there is trust that there was an immediate and powerful need to do so (and is hopefully communicated).

### Idleness

This is hard to measure, but built-in to this testing model is the queue, where one is waiting for the lock to become available so they can continue to work.

## The Solution

This tool!

## Docker

### Build

- Clones the repository and given branch into the image.
- Downloads the cookbooks and their dependencies listed in the `Berksfile`.

Build two images with defaults:

- `chef.delete`
- `chef.upload`
    + Build Args
        - `CHEF_REPO`
            + Defaults to `pagerduty/chef`
        - `CHEF_BRANCH`
            + Defaults to `master`

```
for op in {delete,upload}
do
DOCKER_BUILDKIT=1 docker build \
    --no-cache \
    --progress plain \
    --ssh default \
    -f "Dockerfile.$op" \
    -t "chef.$op" .
done
```

### Run

Downloads the `identity.pem` and `config.rb` files from `S3` and uploads the cookbooks and cookbook components to the location of the Chef Infra Server in `config.rb`.

```
docker run \
    --rm \
    --env AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
    --env AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
    -it chef.upload \
    -i the_identity
```

When running, there is confirmation of the Chef repository and branch that is the source for the cookbooks and other components uploaded to the Chef Infra Server.

```
--------------------
[upload.bash][INFO] Using Chef repository: pagerduty/chef
[upload.bash][INFO]     Using Chef branch: testy
--------------------
```

## More Chef Bullshit

```
wget https://packages.chef.io/files/stable/chef-workstation/0.16.33/ubuntu/18.04/chef-workstation_0.16.33-1_amd64.deb
sudo dpkg -i chef-workstation_0.16.33-1_amd64.deb

knife bootstrap localhost \
    -c .chef/config.rb \
    -U vagrant \
    -p 2222 \
    -i /home/kilgore-trout/projects/vagrantfiles/pagerduty/chef-managed/.vagrant/machines/default/virtualbox/private_key \
    -r "role[twistlock]" \
    --sudo \
    -N testies \
    --yes

```

`https://s3.amazonaws.com/pd-public-files/`

```
<Contents>
<Key>packages/chef_14.13.11-1_amd64.xenial.deb</Key>
<LastModified>2019-06-17T00:09:34.000Z</LastModified>
<ETag>"af5f36649b424bd8430f9f5b9051b7c9-4"</ETag>
<Size>30189144</Size>
<StorageClass>STANDARD</StorageClass>
</Contents>

sudo chef-client -c "$HOME/.chef/config.rb" -j "$HOME/runlist.json" -l info --node-name btoll
```

Q. Where are the cookbooks?
A. `/var/chef/cache/cookbooks`

Q. How do I do another Chef run?
A. `sudo chef-client`

Q. How do I do another Chef run and not sync the cookbooks with those on the Chef Infra Server?
A. `sudo chef-client --skip-cookbook-sync`

Q. Where are the gems stored on the machine by default?
A. `/opt/chef/embedded/lib/ruby/gems/2.6.0/gems/`

