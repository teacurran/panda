namespace :deploy do
  desc "Sets up S3 bucket, SDB domains, video player, admin user, and encoding Profile"
  task :bootstrap, :roles => :app do
    run "cd #{current_path}; script/bootstrap"
  end
end
