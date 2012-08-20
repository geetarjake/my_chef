#
# Cookbook Name:: website
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#Setup non-system user
homedir = '/home/website/'
keyinfile = "#{homedir}.ssh/website_rsa.pub"
keyoutfile = "#{homedir}.ssh/authorized_keys"
# Create non system user and key

`useradd -s /bin/bash website`
`mkdir -p #{homedir}.ssh`
`ssh-keygen -t rsa -f #{homedir}.ssh/website_rsa -P ""`

#create authorized_keys file and copy key 
`touch #{keyoutfile}`


input = File.open(keyinfile)
indata = input.read()

output = File.open(keyoutfile, 'w')
output.write(indata)

output.close()
input.close()
