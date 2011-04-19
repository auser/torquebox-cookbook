node[:torquebox][:deploy_apps].each do |app_name, git_url|
  app_dir = "#{node[:torquebox][:user][:home_dir]}/src/#{app_name}"
  default_environment = node[:torquebox][:default_environment]
  
  git "#{app_dir}" do
    user node[:torquebox][:user][:uid]
    group node[:torquebox][:user][:gid]
    repository git_url
    reference "master"
    action :sync
  end

  directory "#{app_dir}" do
    owner node[:torquebox][:user][:uid]
    group node[:torquebox][:user][:gid]
  end

  execute "Run bundler with #{app_name}" do
    # user node[:torquebox][:user][:uid]
    # group node[:torquebox][:user][:gid]
    environment default_environment
    cwd app_dir
    command <<-EOE
    bundle install
    EOE
  end

  execute "Deploy #{app_name}" do
    user node[:torquebox][:user][:uid]
    group node[:torquebox][:user][:gid]
    cwd app_dir
    environment default_environment
    command <<-EOE
    #{default_environment.map {|k,v| "#{k}=#{v}"}.join(" ")} rake torquebox:deploy:archive
    EOE
  end
end
