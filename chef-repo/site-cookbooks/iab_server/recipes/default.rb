#
# Cookbook Name:: data_manager
# Recipe:: default
#
# Copyright 2011, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# create a database for IAB, then create a user with access to the new database instance
include_recipe "database"
mysql_connection_info = {:host => 'localhost', :username => 'root', :password => node['mysql']['server_root_password']}
mysql_database 'iab_db' do
  connection mysql_connection_info
  action :create
end
mysql_database_user 'iab' do
  connection mysql_connection_info
  password 'ia4bbb'
  action :create
  action :grant
end

# install the python mysql driver
package "python-mysqldb"

# pull down the app from github
deploy_to = data_bag_item("apps", "iab_server")['deploy_to']
package "git"
include_recipe "application"

# work out what this node is called for apache
server_aliases = [ node.fqdn ]
if node.has_key?("ec2")
  server_aliases << node.ec2.public_hostname
end

# set up the app as a web_app served by apache
web_app "iab_server" do
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
