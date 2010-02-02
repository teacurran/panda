namespace :deploy do
  desc "Install system rc.d startup scripts"
  task :install_system_daemons, :roles => :app do
    sudo "echo .; cd #{current_path}; rake dev:install_system_daemons"
  end
end
