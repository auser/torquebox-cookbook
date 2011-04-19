u = node[:torquebox][:user]  
group u['gid']

user u['uid'] do
  gid u['gid']
  shell "/bin/bash"
  home u['home_dir']
  system true
end

group 'rvm' do
  members u['uid']
  append true
end

directory "#{u['home_dir']}/.ssh" do
  owner u['uid']
  group u['gid']
  recursive true
  mode "0700"
end

template "#{u['home_dir']}/.ssh/authorized_keys" do
  source "authorized_keys.erb"
  owner u['uid']
  group u['gid']
  mode "0600"
  variables :ssh_keys => u['ssh_keys']
end

template "#{u['home_dir']}/.profile" do
  source "profile.erb"
  owner u['uid']
  group u['gid']
  mode "0755"
end

