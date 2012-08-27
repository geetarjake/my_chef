#
# Cookbook Name:: website
# Recipe:: default
#
# Copyright 2012, JGreen
#
# All rights reserved - Do Not Redistribute
#

require 'fileutils'
include_recipe "users"

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

## Begin Cheating Hack!!
#`useradd -s /bin/bash website`
## End Cheating Hack!!
puts "\nabout to add a user, brace yourself\n"

user "website" do
     action :create
     home "#{homedir}"
     shell "/bin/bash"
     supports :manage_home=>true
end

FileUtils.chmod 0755, "#{homedir}" 

if File.exists?("#{homedir}/.ssh") && File.directory?("#{homedir}/.ssh")
  puts ".ssh dir exists, moving on\n"
else
  puts ".ssh dir does not exist, lets create it and move on\n"
  FileUtils.mkdir "#{homedir}/.ssh"
end

if File.exists?(keyoutfile)
  puts "\n **#{keyoutfile} exists, moving on\n"
else
  puts "\n ** #{keyoutfile} doesn't exist, lets create it and move on\n"
  `ssh-keygen -t rsa -f #{homedir}/.ssh/website_rsa -P \"\"`

FileUtils.touch "#{keyoutfile}"


input = File.open(keyinfile)
indata = input.read()

output = File.open(keyoutfile, 'w')
output.write(indata)

output.close()
input.close()

end

#Setup docroot and Apache vhost
if File.exists?(docroot) && File.directory?(docroot)
  puts "\n **docroot: #{docroot} exists, moving on\n"
else
  puts "\n **docroot #{docroot} doesn't exist, lets create it, setup the apache conf,  and move on\n"
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
end
