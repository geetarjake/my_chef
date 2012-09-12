#
# Cookbook Name:: website
# Recipe:: default
#
# Copyright 2012, JGreen
#
# All rights reserved - Do Not Redistribute
#

# install Ruby-Shadow, for password support in user resource
package "ruby-shadow" do
  action :install
end

#set some variabls to keep things tidy
homedir = '/home/website'
docroot = "#{homedir}/public_html"
keyinfile = "#{homedir}/.ssh/website_rsa.pub"
keyoutfile = "#{homedir}/.ssh/authorized_keys"


website_key = data_bag_item('keys', 'website')

title = node['website']['title']

index = "#{docroot}/index.html"

# start using resources
user "website" do
  action :create
  home "#{homedir}"
  shell "/bin/bash"
  supports :manage_home => true
end

directory homedir do
  mode "0711"
end

directory "#{homedir}/.ssh" do
  owner "website"
  group "website"
  mode  "0755"
  action :create
 end

file keyoutfile do
  action :create_if_missing
  content website_key['ssh_keys']
end

directory docroot do
  owner "website"
  group "website"
  mode  "0755"
  action :create
end

web_app "mysite" do
  template "mysite.conf.erb"
  server_name "mysite.com"
  server_aliases [ "#{node['domain']}", node['fqdn'] ]
  docroot docroot
end

template "#{docroot}/index.html" do
  source "index.html.erb"
  mode 0644
  owner "website"
  group "website"
end

#loop to create users based on the encrypted data bag "users"
node['userlist'].each_key do |u|

 users_data = Chef::EncryptedDataBagItem.load("users",u)

  user u do
    shell users_data["shell"]
    password users_data["pass"]
  end
end

