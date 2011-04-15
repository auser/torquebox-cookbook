group 'rvm'

%w(coreutils autoconf curl git-core ruby bison build-essential zlib1g-dev libssl-dev libreadline5-dev).each do |pkg|
  package pkg do
    action :install
  end
end

bash "install RVM" do
  user "root"
  code "bash < <( curl -L http://rvm.beginrescueend.com/releases/rvm-install-head )"
  not_if "which rvm"
end
cookbook_file "/etc/profile.d/rvm.sh"

node[:torquebox][:rvm][:rubies].each do |ruby_version|
  bash "install #{ruby_version} with RVM" do
    user "root"
    code "rvm install #{ruby_version}"
    not_if "rvm list | grep #{ruby_version}"
  end
end

bash "make #{node[:torquebox][:rvm][:default_ruby]} the default ruby" do
  user "root"
  code "rvm --default #{node[:torquebox][:rvm][:default_ruby]}"
  not_if "rvm list | grep #{node[:torquebox][:rvm][:default_ruby]} | grep '=>'"
end

# INSTALL torquebox GEMS
execute "install torquebox GEMS" do
  # gem install torquebox torquebox-messaging-container torquebox-naming-container torquebox-capistrano-support torquebox-rake-support torquebox-vfs bundler --pre --no-ri --no-rdoc --source http://rubygems.torquebox.org
  command <<-EOC
rvm use jruby-1.6.0@global
gem install bundler --no-ri --no-rdoc
  EOC
  not_if "rvm use jruby-1.6.0@global; gem list | grep torquebox"
end

gem_package "bundler"
