# https://github.com/torquebox/backstage.git

backstage_dir = "/home/torquebox/src/backstage"

git "#{backstage_dir}" do
  repository "git://github.com/auser/backstage.git"
  reference "master"
  action :sync
end 

# INSTALL torquebox GEMS
execute "install torquebox GEMS" do
  command <<-EOC
rvm use jruby-1.6.0@backstage --create
gem install torquebox torquebox-messaging-container torquebox-naming-container torquebox-capistrano-support torquebox-rake-support torquebox-vfs bundler --pre --no-ri --no-rdoc --source http://rubygems.torquebox.org
gem install bundler --no-ri --no-rdoc
  EOC
  not_if "rvm use jruby-1.6.0@backstage; gem list | grep bundler"
end

gem_package "bundler"

execute "Run bundler with backstage" do
  command <<-EOE
  cd #{backstage_dir}
  rvm use jruby-1.6.0@backstage
  jruby-1.6.0 -S bundle install
  EOE
end

execute "Deploy backstage" do
  command <<-EOE
  cd #{backstage_dir}
  jruby-1.6.0 -S rake torquebox:deploy:archive
  EOE
end