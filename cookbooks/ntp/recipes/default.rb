#
# Cookbook Name:: ntp
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#
package "ntp" do
    action [:install]
end
 
template "/etc/ntp.conf" do
    source "ntp.conf.erb"
    variables( :ntp_server => "utcnist.colorado.edu " )
    notifies :restart, "service[ntpd]"
end
 
service "ntpd" do
    action [:enable,:start]
end
