#
# Cookbook Name:: website
# Recipe:: default
#
# Copyright 2012, JGreen
#
# All rights reserved - Do Not Redistribute
#

require 'fileutils'
#include_recipe "users"

homedir = '/home/website'
docroot = "#{homedir}/public_html"
keyinfile = "#{homedir}/.ssh/website_rsa.pub"
keyoutfile = "#{homedir}/.ssh/authorized_keys"

website_key = data_bag_item('keys', 'website')

#Variables for index.html, content, etc
title = node[:title]

index = "#{docroot}/index.html"
content = <<BODY
<html>
<head>
<title>#{title}</title>
</head>
<body>
Here is the body of my test index.html page.<br>
You don't like it?<br>
Give me a break, I'm still learning Chef. <br>
</body>
BODY

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

#Begin hack for SSH key
#
#if File.exists?(keyoutfile)
#  puts "\n **#{keyoutfile} exists, moving on\n"
#else
#  puts "\n ** #{keyoutfile} doesn't exist, lets create it and move on\n"
#  `ssh-keygen -t rsa -f #{homedir}/.ssh/website_rsa -P \"\"`

#FileUtils.touch "#{keyoutfile}"


#input = File.open(keyinfile)
#indata = input.read()

#output = File.open(keyoutfile, 'w')
#output.write(indata)

#output.close()
#input.close()

#end
#
#End hack for SSH key



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

file "#{docroot}/index.html" do
  owner "website"
  group "website"
  action :create
  content content
end


