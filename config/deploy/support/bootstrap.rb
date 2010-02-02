namespace :deploy do
  desc "Install rubygems needed for .. EVERTHING"
  task :install_gems do
    sudo "echo .; ruby #{current_path}/script/install_gems"
  end

  desc "Sets up S3 bucket, SDB domains, video player, admin user, and encoding Profile"
  task :bootstrap, :roles => :app do
    run "cd #{current_path}; script/bootstrap"
  end
end
