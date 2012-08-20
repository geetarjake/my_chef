#
# Cookbook Name:: website
# Recipe:: default
#
# Copyright 2012, JGreen
#
# All rights reserved - Do Not Redistribute
#

require 'fileutils'

#Setup non-system user
homedir = '/home/website'
docroot = "#{homedir}/public_html"
keyinfile = "#{homedir}/.ssh/website_rsa.pub"
keyoutfile = "#{homedir}/.ssh/authorized_keys"

#Variables for index.html, content, etc
index = "#{docroot}/index.html"
content = <<BODY
<html>
Here is the body of my test index.html page.<br>
You don't like it?<br>
Give me a break, I'm still learning Chef. <br>
BODY


# Create non system user and key
# along with setting proper homedir/docroot perms
`useradd -s /bin/bash website`

FileUtils.mkdir "#{homedir}/.ssh"

`ssh-keygen -t rsa -f #{homedir}/.ssh/website_rsa -P ""`

FileUtils.chmod 0755, "#{homedir}"
#FileUtils.chown_R 'website', 'website', "#{homedir}"

#create authorized_keys file and copy key 
FileUtils.touch "#{keyoutfile}"


input = File.open(keyinfile)
indata = input.read()

output = File.open(keyoutfile, 'w')
output.write(indata)

output.close()
input.close()

#Setup Apache vhost
FileUtils.mkdir "#{docroot}"

web_app "mysite" do
     template "mysite.conf.erb"
     server_name "mysite.com"
     server_aliases [ "#{node['domain']}", node['fqdn'] ]
     docroot "#{docroot}"
   end

FileUtils.chmod 0755, "#{docroot}"

#Create index.html, then write default data to it

FileUtils.touch "#{docroot}/index.html"


target = File.open(index, 'w')
target.write(content)
target.close()

`chown -R website:website #{homedir}`
