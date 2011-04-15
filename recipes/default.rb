#
# Cookbook Name:: torquebox
# Recipe:: default
#
# Copyright 2011, Ari Lerner
#
# All rights reserved - Do Not Redistribute
#

include_recipe "torquebox::users"
include_recipe "torquebox::rvm"

gem_package "chef"

# directory
root_dir            = "/home/torquebox"
current_torque_dir  = "#{root_dir}/torquebox-current"
src_dir             = "#{root_dir}/src"
apps_dir            = "#{root_dir}/apps"

# Temporary directory
directory "#{src_dir}" do
  owner "torquebox"
  group "torquebox"
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
    
    remote_file "#{src_dir}/#{zip_filename}" do
      source "http://torquebox.org/torquebox-dev.zip"
      owner "torquebox"
      group "torquebox"
      mode 0644
      checksum "ab7cd48e286c5f4fb5ccabfbbe38ae3caefa8007e56ba316bcf00f085aea553e"
    end
    
    # Because the dev is packed into an odd directory, we have to unpack it here first
    execute "torquebox-src-unpack" do
      cwd "#{src_dir}"
      command <<-EOC
unzip -uq #{zip_filename} -d #{unpacked_directory_name}-tmp
mv #{unpacked_directory_name}-tmp/* #{unpacked_directory_name}
rm -rf #{unpacked_directory_name}-tmp
chown -R torquebox:torquebox #{unpacked_directory_name}
      EOC
    end
    
  # Otherwise
  when 'stable'
    version_str = "#{node[:torquebox][:package][:version][:major]}.#{node[:torquebox][:package][:version][:minor]}.#{node[:torquebox][:package][:version][:incremental]}"
    zip_filename = "torquebox-dist-#{version_str}-bin.zip"
    unpacked_directory_name = "torquebox-#{version_str}"
    
    remote_file "#{src_dir}/#{zip_filename}" do
      source "http://repository.torquebox.org/maven2/releases/org/torquebox/torquebox-dist/#{version_str}/#{zip_filename}"
      owner "torquebox"
      group "torquebox"
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
  owner "torquebox"
  group "torquebox"
end

execute "chown torquebox" do
  cwd "#{src_dir}"
  command "chown -R torquebox:torquebox #{unpacked_directory_name}"
end
  
link "#{current_torque_dir}" do
  to "#{src_dir}/#{unpacked_directory_name}"
  owner "torquebox"
  group "torquebox"
end

directory "#{apps_dir}" do
  mode 0777
end

directory "#{apps_dir}" do
  mode 0777
end

# Allow us to create a deployment descriptor
directory "#{current_torque_dir}/jboss/server/default/deploy" do
  mode 0777
end

include_recipe "torquebox::backstage"