# chef-solo

`solo.rb`

```
cookbook_path "/home/vagrant/chef"
data_bag_path '/var/chef-solo/data_bags'
file_cache_path "/home/vagrant/cache"
recipe_url "http://localhost/chef-solo.tgz"
```

`web.json`

```
{
    "run_list": [ "recipe[first_cookbook]" ]
}
```

Run `setup_http.sh` to start the Python simple server.  This will serve everything in the `HOME` directory, including the tarball copied from `/vagrant` in the `./scripts/user.sh` script during `vagrant up`.

```
chef-solo -c "$HOME/solo.rb" -j "$HOME/web.json" --chef-license accept
```

Use a URL for cookbook and JSON data:

```
chef-solo -c "$HOME/solo.rb" -j http://www.example.com/node.json --recipe-url http://www.example.com/chef-solo.tar.gz
```

To download PagerDuty gems:

```
bundle config set --global pagerduty.jfrog.io $JFROG_USERNAME:$JFROG_PASSWORD
bundle install
```

## References

- [chef-solo](https://docs.chef.io/chef_solo/)

