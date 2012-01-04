#
# Cookbook Name:: data_manager
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

deploy_to = data_bag_item("apps", "key_value_server")['deploy_to']

package "git"

include_recipe "apache2"
include_recipe "django"
include_recipe "application"

# app = node.run_state[:current_app]
# server_aliases = [ "#{app['id']}.#{node['domain']}", node.fqdn ]
server_aliases = [ node.fqdn ]

if node.has_key?("ec2")
  server_aliases << node.ec2.public_hostname
end

web_app "key_value_server" do
  if node.has_key?("ec2")
    server_name node.ec2.public_hostname
  else
    server_name node.fqdn
  end
  server_aliases server_aliases
  docroot "#{deploy_to}"
  template "apache.conf.erb"
end

# Watch out: hard-coded path to virtual env in django.wsgi
template "#{deploy_to}/current/django.wsgi" do
  source "django.wsgi.erb"
  mode 0666
  variables({:deploy_to=>deploy_to})
end

############################
# THERE MUST BE A BETTER WAY THAN THIS?
# The intent is to remove the default apache webapp which steals our requests.
############################
execute "sudo rm /etc/apache2/sites-enabled/000*" do
  only_if "test -f /etc/apache2/sites-enabled/000*"
end
