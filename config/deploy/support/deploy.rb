namespace :deploy do
  desc "Restart Merb"
  task :restart, :roles => :app do
    sudo "/etc/init.d/panda restart"
    sudo "/etc/init.d/panda.encoder restart"
    sudo "/etc/init.d/panda.notifier restart"
  end

  desc "Start Merb"
  task :start, :roles => :app do
    sudo "/etc/init.d/panda stop"
    sudo "/etc/init.d/panda.encoder start"
    sudo "/etc/init.d/panda.notifier start"
  end
  
  desc "Stop Merb"
  task :stop, :roles => :app do
    sudo "/etc/init.d/panda stop"
    sudo "/etc/init.d/panda.encoder stop"
    sudo "/etc/init.d/panda.notifier stop"
  end
end
