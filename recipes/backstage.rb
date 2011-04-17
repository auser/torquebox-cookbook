# https://github.com/torquebox/backstage.git

backstage_dir = "/home/torquebox/src/backstage"

git "#{backstage_dir}" do
  repository "git://github.com/auser/backstage.git"
  reference "master"
  action :sync
end 

execute "install torquebox GEMS" do
  command <<-EOC
rvm use #{node[:torquebox][:rvm][:default_ruby]}@backstage --create
gem install torquebox --pre --no-ri --no-rdoc --source http://rubygems.torquebox.org
  EOC
  not_if "rvm use #{node[:torquebox][:rvm][:default_ruby]}@backstage; gem list | grep bundler"
end

execute "Run bundler with backstage" do
  cwd backstage_dir
  command <<-EOE
  rvm use #{node[:torquebox][:rvm][:default_ruby]}@backstage --create
  #{node[:torquebox][:rvm][:default_ruby]} -S bundle install
  EOE
end

execute "Deploy backstage" do
  cwd backstage_dir
  command <<-EOE
  #{node[:torquebox][:rvm][:default_ruby]} -S rake torquebox:deploy:archive
  EOE
end