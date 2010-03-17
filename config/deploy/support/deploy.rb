namespace :deploy do
  desc "Immortalize Merb & services (cron job makes sure they keep running)"
  task :immortalize_daemons, :roles => :app do
    sudo "/opt/ruby-enterprise-1.8.7-2009.10/bin/immortalize --log-location /home/prod/.immortalize setup"
  end

  desc "Start Merb & services"
  task :start, :roles => :app do
    run "/opt/ruby-enterprise-1.8.7-2009.10/bin/immortalize --notify=rw-staging@mutuallyhuman.com run \"cd \\\"#{current_path}\\\"; /opt/ruby-enterprise-1.8.7-2009.10/bin/merb -e #{merb_env} -p 4000 1>>log/#{merb_env}.log 2>&1\""
    run "/opt/ruby-enterprise-1.8.7-2009.10/bin/immortalize --notify=rw-staging@mutuallyhuman.com run \"cd \\\"#{current_path}\\\"; /opt/ruby-enterprise-1.8.7-2009.10/bin/merb -e #{merb_env} -p 4001 -r bin/encoder.rb 1>>log/encoder.#{merb_env}.log 2>&1\""
    run "/opt/ruby-enterprise-1.8.7-2009.10/bin/immortalize --notify=rw-staging@mutuallyhuman.com run \"cd \\\"#{current_path}\\\"; /opt/ruby-enterprise-1.8.7-2009.10/bin/merb -e #{merb_env} -p 4002 -r bin/notifier.rb 1>>log/notifier.#{merb_env}.log 2>&1\""
  end
  
  desc "Stop Merb & services"
  task :stop, :roles => :app do
    run "/opt/ruby-enterprise-1.8.7-2009.10/bin/immortalize stop \"cd \\\"#{current_path}\\\"; /opt/ruby-enterprise-1.8.7-2009.10/bin/merb -e #{merb_env} -p 4000 1>>log/#{merb_env}.log 2>&1\""
    run "/opt/ruby-enterprise-1.8.7-2009.10/bin/immortalize stop \"cd \\\"#{current_path}\\\"; /opt/ruby-enterprise-1.8.7-2009.10/bin/merb -e #{merb_env} -p 4001 -r bin/encoder.rb 1>>log/encoder.#{merb_env}.log 2>&1\""
    run "/opt/ruby-enterprise-1.8.7-2009.10/bin/immortalize stop \"cd \\\"#{current_path}\\\"; /opt/ruby-enterprise-1.8.7-2009.10/bin/merb -e #{merb_env} -p 4002 -r bin/notifier.rb 1>>log/notifier.#{merb_env}.log 2>&1\""
  end

  desc "Restart Merb & services"
  task :restart, :roles => :app do
    run "/opt/ruby-enterprise-1.8.7-2009.10/bin/immortalize stop \"cd \\\"#{current_path}\\\"; /opt/ruby-enterprise-1.8.7-2009.10/bin/merb -e #{merb_env} -p 4000 1>>log/#{merb_env}.log 2>&1\""
    run "/opt/ruby-enterprise-1.8.7-2009.10/bin/immortalize --notify=rw-staging@mutuallyhuman.com run \"cd \\\"#{current_path}\\\"; /opt/ruby-enterprise-1.8.7-2009.10/bin/merb -e #{merb_env} -p 4000 1>>log/#{merb_env}.log 2>&1\""
    run "/opt/ruby-enterprise-1.8.7-2009.10/bin/immortalize stop \"cd \\\"#{current_path}\\\"; /opt/ruby-enterprise-1.8.7-2009.10/bin/merb -e #{merb_env} -p 4001 -r bin/encoder.rb 1>>log/encoder.#{merb_env}.log 2>&1\""
    run "/opt/ruby-enterprise-1.8.7-2009.10/bin/immortalize --notify=rw-staging@mutuallyhuman.com run \"cd \\\"#{current_path}\\\"; /opt/ruby-enterprise-1.8.7-2009.10/bin/merb -e #{merb_env} -p 4001 -r bin/encoder.rb 1>>log/encoder.#{merb_env}.log 2>&1\""
    run "/opt/ruby-enterprise-1.8.7-2009.10/bin/immortalize stop \"cd \\\"#{current_path}\\\"; /opt/ruby-enterprise-1.8.7-2009.10/bin/merb -e #{merb_env} -p 4002 -r bin/notifier.rb 1>>log/notifier.#{merb_env}.log 2>&1\""
    run "/opt/ruby-enterprise-1.8.7-2009.10/bin/immortalize --notify=rw-staging@mutuallyhuman.com run \"cd \\\"#{current_path}\\\"; /opt/ruby-enterprise-1.8.7-2009.10/bin/merb -e #{merb_env} -p 4002 -r bin/notifier.rb 1>>log/notifier.#{merb_env}.log 2>&1\""
  end
end
