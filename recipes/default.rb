#
# Cookbook Name:: mysql_component
# Recipe:: default
#
# Copyright 2014, Qubell
#
# All rights reserved - Do Not Redistribute
#

node.set['mysql']['tunable']['max_allowed_packet'] = '50M'

case node[:platform] 
  when "ubuntu"
    execute "update packages cache" do
      command "apt-get update"
    end
  end

include_recipe "mysql::server"

remote_file "#{node["mysql_component"]["tmp_path"]}/mysql-2.9.1-x86_64-linux.gem" do
  source node["mysql_component"]["mysql_gem_url"]
end

#execute "install mysql_gem" do
#  command "/opt/chef/embedded/bin/gem install --local #{node["mysql_component"]["tmp_path"]}/mysql-2.9.1.gem"
#end 

gem_package "mysql-2.9.1" do
  source "#{node["mysql_component"]["tmp_path"]}/mysql-2.9.1-x86_64-linux.gem"
  version "2.9.1"
  action :install
end

case node[:platform_family]
  when "rhel"
    service "iptables" do
      action :stop
    end

    directory '/etc/mysql' do
      owner 'root'
      group 'root'
      mode '0755'
      action :create
    end

    file '/etc/mysql/my.cnf' do
      owner 'root'
      group 'root'
      mode 0644
      content lazy { ::File.open("/etc/my.cnf").read }
      notifies :restart, "service[mysql]"
    end

  when "debian"
    service "ufw" do
      action :stop
    end
  end
