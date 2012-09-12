#
# Cookbook Name:: wordpress
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

homedir = '/home/website'
docroot = "#{homedir}/public_html"
wproot = "#{docroot}/wordpress"
mysql_connection_info = {:host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']}


remote_file "#{docroot}/wordpress.tar.gz" do
  source "http://wordpress.org/latest.tar.gz"
  mode "0644"
  owner "website"
  group "website"
end

bash "unpack_wordpress" do
  user "website"
  group "website"
  cwd docroot
  code <<-TAR
  tar -xzf #{docroot}/wordpress.tar.gz
  TAR
end

#file "#{wproot}/wp-config.php" do
#  user "website"
#  group "website"
#  mode "0644"
#  action :create_if_missing
#end

template "/root/.my.cnf" do
  source "root.my.cnf.erb"
  owner "root"
  group "root"
  mode "0600"
end


mysql_database "wordpress" do
 # connection ({:host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']})
  connection mysql_connection_info
  action :create
end

m_creds = Chef::EncryptedDataBagItem.load("creds", "mysql")

mysql_database_user "wordpress" do
  connection mysql_connection_info
  password m_creds["pass"]
  database_name "wordpress"
  host "localhost"
  action :grant
end 

template "#{wproot}/wp-config.php" do
  source "wp-config.php.erb"
  user "website"
  group "website"
  mode "0644"
end

