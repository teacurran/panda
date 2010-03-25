namespace :deploy do
  desc "Install rubygems needed for .. EVERTHING"
  task :install_gems do
    run <<-BASH
      if [ `which bundle` ]; then 
        cd #{current_path} && bundle install ; 
      else  
        echo 'Please install bundler 0.9.7 rubygem' ;
      fi
    BASH
  end

  desc "Sets up S3 bucket, SDB domains, video player, admin user, and encoding Profile"
  task :bootstrap, :roles => :app do
    run "cd #{current_path}; MERB_ENV=#{merb_env} script/bootstrap"
  end
end
