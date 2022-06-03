# See http://docs.chef.io/workstation/config_rb/ for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "btoll"
client_key               "#{current_dir}/btoll.pem"
chef_server_url          "https://api.chef.io/organizations/onf"
cookbook_path            ["#{current_dir}/../cookbooks"]
