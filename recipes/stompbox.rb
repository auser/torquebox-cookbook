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
  rvm use jruby-1.6.0@stompbox
  jruby-1.6.0 -S bundle install
EOE
end

execute "Deploy backstage" do
  cwd stompbox_dir
  command <<-EOE
  jruby-1.6.0 -S rake torquebox:deploy:archive
EOE
end