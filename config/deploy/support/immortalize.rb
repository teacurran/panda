namespace :immortalize do
  desc "Immortalize Merb & services (cron job makes sure they keep running)"
  task :setup, :roles => :app do
    run "#{immortalize_cmd} setup"
    run "#{immortalize_cmd} stop all"
    run "#{immortalize_cmd} remove all"
  end

  desc "Start Merb & services"
  task :start, :roles => :app do
    run "#{immortalize_cmd} --notify=rw-staging@mutuallyhuman.com run \"cd \\\"#{current_path}\\\"; #{merb_cmd} -e #{merb_env} -p 4000 1>>log/#{merb_env}.log 2>&1\""
    run "#{immortalize_cmd} --notify=rw-staging@mutuallyhuman.com run \"cd \\\"#{current_path}\\\"; #{merb_cmd} -e #{merb_env} -p 4001 -r bin/encoder.rb 1>>log/encoder.#{merb_env}.log 2>&1\""
    run "#{immortalize_cmd} --notify=rw-staging@mutuallyhuman.com run \"cd \\\"#{current_path}\\\"; #{merb_cmd} -e #{merb_env} -p 4002 -r bin/notifier.rb 1>>log/notifier.#{merb_env}.log 2>&1\""
  end
  
  desc "Stop Merb & services"
  task :stop, :roles => :app do
    run "#{immortalize_cmd} stop \"cd \\\"#{current_path}\\\"; #{merb_cmd} -e #{merb_env} -p 4000 1>>log/#{merb_env}.log 2>&1\""
    run "#{immortalize_cmd} stop \"cd \\\"#{current_path}\\\"; #{merb_cmd} -e #{merb_env} -p 4001 -r bin/encoder.rb 1>>log/encoder.#{merb_env}.log 2>&1\""
    run "#{immortalize_cmd} stop \"cd \\\"#{current_path}\\\"; #{merb_cmd} -e #{merb_env} -p 4002 -r bin/notifier.rb 1>>log/notifier.#{merb_env}.log 2>&1\""
  end

  desc "Restart Merb & services"
  task :restart, :roles => :app do
    find_and_execute_task("immortalize:setup")
    find_and_execute_task("immortalize:start")
  end
end
