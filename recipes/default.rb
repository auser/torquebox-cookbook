#
# Cookbook Name:: torquebox
# Recipe:: default
#
# Copyright 2011, Ari Lerner
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apt"
include_recipe "git"

template "/etc/profile" do
  source "profile.erb"
  owner "root"
  group "root"
  mode "0755"
end

package "unzip"

case node[:platform]
when "ubuntu","CentOS","RedHat","Fedora"
  %w(openjdk-6-jre openjdk-6-jdk).each do |pkg|
    package pkg do
      action :install
    end
  end
end


include_recipe "torquebox::users"
# include_recipe "torquebox::rvm"

gem_package "chef"

# directory
root_dir            = node[:torquebox][:root_dir]
current_torque_dir  = node[:torquebox][:current_torque_dir]
src_dir             = node[:torquebox][:src_dir]
apps_dir            = node[:torquebox][:apps_dir]

default_environment = node[:torquebox][:default_environment]
  
# Temporary directory
directory "#{src_dir}" do
  owner node[:torquebox][:user][:uid]
  group node[:torquebox][:user][:gid]
  mode 0755
  action :create
  recursive true
end

case node[:torquebox][:package][:type]
when 'binary'  
  case node[:torquebox][:package][:build]
  when 'devbuild'
    base_uri    = "http://torquebox.org"
    zip_filename = "torquebox-dev.zip"
    unpacked_directory_name = "torquebox-dev"
    
    # Because the dev is packed into an odd directory, we have to unpack it here first
    execute "torquebox-src-unpack" do
      cwd "#{src_dir}"
      command <<-EOC
unzip -uq #{zip_filename} -d #{unpacked_directory_name}-tmp
rm -rf #{unpacked_directory_name}
mv #{unpacked_directory_name}-tmp/* #{unpacked_directory_name}
rm -rf #{unpacked_directory_name}-tmp
chown -R #{node[:torquebox][:user][:uid]}:#{node[:torquebox][:user][:gid]} #{unpacked_directory_name}
      EOC
      environment default_environment
      action :nothing
    end
        
    remote_file "#{src_dir}/#{zip_filename}" do
      source "http://torquebox.org/torquebox-dev.zip"
      owner node[:torquebox][:user][:uid]
      group node[:torquebox][:user][:gid]
      mode 0644
      checksum "0bca6b1f6862155175e609852309aaa61955adc275527f9005956d9638695279"
      notifies :run, resources(:execute => "torquebox-src-unpack")
    end
    
  # Otherwise
  when 'stable'
    version_str = "#{node[:torquebox][:package][:version][:major]}.#{node[:torquebox][:package][:version][:minor]}.#{node[:torquebox][:package][:version][:incremental]}"
    zip_filename = "torquebox-dist-#{version_str}-bin.zip"
    unpacked_directory_name = "torquebox-#{version_str}"
    
    remote_file "#{src_dir}/#{zip_filename}" do
      source "http://repository.torquebox.org/maven2/releases/org/torquebox/torquebox-dist/#{version_str}/#{zip_filename}"
      owner node[:torquebox][:user][:uid]
      group node[:torquebox][:user][:gid]
      mode 0644
      checksum "#{node[:torquebox][:package][:checksum]}"
    end
    
    execute "torquebox-src-unpack" do
      cwd "#{src_dir}"
      command "unzip -uq #{zip_filename} -d #{unpacked_directory_name}"
    end
    
  end
end

directory "#{src_dir}/#{unpacked_directory_name}" do
  owner node[:torquebox][:user][:uid]
  group node[:torquebox][:user][:gid]
end

execute "chown torquebox" do
  cwd "#{src_dir}"
  command "chown -R #{node[:torquebox][:user][:uid]}:#{node[:torquebox][:user][:gid]} #{unpacked_directory_name}"
end
  
link "#{current_torque_dir}" do
  to "#{src_dir}/#{unpacked_directory_name}"
  owner node[:torquebox][:user][:uid]
  group node[:torquebox][:user][:gid]
end
# Link default directory too
link "/usr/local/jboss" do
  to "#{src_dir}/#{unpacked_directory_name}/jboss"
  owner node[:torquebox][:user][:uid]
  group node[:torquebox][:user][:gid]
end

directory "#{apps_dir}" do
  owner node[:torquebox][:user][:uid]
  group node[:torquebox][:user][:gid]
  mode 0755
end

# Allow us to create a deployment descriptor
directory "#{current_torque_dir}" do
  owner node[:torquebox][:user][:uid]
  group node[:torquebox][:user][:gid]
  mode 0755
  recursive true
end

execute "install bundler gem" do
  command <<-EOC
jruby -S gem install bundler
  EOC
  not_if "gem list | grep bundler"
  environment default_environment
end

execute "install torquebox gems" do
  command <<-EOC
jruby -S gem install torquebox --pre --no-ri --no-rdoc --source http://rubygems.torquebox.org
  EOC
  not_if "gem list | grep torquebox"
  environment default_environment
end

directory "#{node[:torquebox][:user][:home_dir]}/log" do
  owner node[:torquebox][:user][:uid]
  group node[:torquebox][:user][:gid]
end

link "/etc/init.d/jboss" do
  to "#{current_torque_dir}/jboss/bin/jboss_init_redhat.sh"
  owner node[:torquebox][:user][:uid]
  group node[:torquebox][:user][:gid]
end

template "/etc/environment" do
  source "environment.erb"
  owner "root"
  group "root"
  mode "0755"
end

template "#{node[:torquebox][:current_torque_dir]}/jboss/bin/run.conf" do
  source "run.conf.erb"
  owner "root"
  group "root"
  mode "0755"
end

service "jboss" do
  # start_command "/bin/bash #{current_torque_dir}/jboss/bin/run.sh -c default -b 0.0.0.0"
  # stop_command "/bin/bash #{current_torque_dir}/jboss/bin/shutdown.sh"
  supports :restart => true
  action [ :enable, :start ]
end


directory "#{apps_dir}" do
  owner node[:torquebox][:user][:uid]
  group node[:torquebox][:user][:gid]
  mode 0777
  recursive true
end

include_recipe "torquebox::apps"
