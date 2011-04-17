# https://github.com/torquebox/backstage.git

stompbox_dir = "/home/torquebox/src/stompbox"

git "#{stompbox_dir}" do
  repository "git://github.com/torquebox/stompbox.git"
  reference "master"
  action :sync
end 

gem_package "bundler"

execute "Run bundler with stompbox" do
  cwd stompbox_dir
  command <<-EOE
  rvm use #{node[:torquebox][:rvm][:default_ruby]}@stompbox --create
  #{node[:torquebox][:rvm][:default_ruby]} -S bundle install
EOE
end

execute "Deploy backstage" do
  cwd stompbox_dir
  command <<-EOE
  #{node[:torquebox][:rvm][:default_ruby]} -S rake torquebox:deploy:archive
EOE
end