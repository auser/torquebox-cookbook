default.torquebox.root_dir            = "#{node[:torquebox][:user][:home_dir]}"
default.torquebox.current_torque_dir  = "#{node[:torquebox][:user][:home_dir]}/torquebox-current"
default.torquebox.src_dir             = "#{node[:torquebox][:user][:home_dir]}/src"
default.torquebox.apps_dir            = "#{node[:torquebox][:user][:home_dir]}/apps"
default.torquebox.deploy_apps         = {
                                          :backstage => "git://github.com/torquebox/backstage.git",
                                          :stompbox => "git://github.com/torquebox/stompbox.git"
                                        }
default.torquebox.default_environment = {
  'TORQUEBOX_HOME' => "#{node[:torquebox][:current_torque_dir]}",
  'JBOSS_HOME' => "#{node[:torquebox][:current_torque_dir]}/jboss",
  'JRUBY_HOME' => "#{node[:torquebox][:current_torque_dir]}/jruby", 
  'PATH' => "#{node[:torquebox][:current_torque_dir]}/jruby/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"}