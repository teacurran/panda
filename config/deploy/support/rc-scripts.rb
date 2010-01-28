namespace :deploy do
  desc "Install rubygems needed for .. EVERTHING"
  task :install_gems do
    sudo "echo .; ruby #{current_path}/script/install_gems"
  end

  desc "Install system rc.d startup scripts"
  task :install_system_daemons, :roles => :app do
    sudo "echo .; cd #{current_path}; rake dev:install_system_daemons"
  end
end
