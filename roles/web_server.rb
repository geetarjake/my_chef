name "web_server"
description "My First Apache Role"
run_list{
  "recipe[ntp]",
  "recipe[apache2]",
  "recipe[apache2::mod_ssl]",
}
default_attributes "apache2" => { "listen_ports" => [ "80", "443" ] }
override_attributes "apache2" => { "max_children" => "50" }
