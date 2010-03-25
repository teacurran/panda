$IMMORTALIZE = "/opt/ruby-enterprise-1.8.7-2009.10/bin/immortalize"
$MERB = "/opt/ruby-enterprise-1.8.7-2009.10/bin/merb"

namespace :deploy do
  desc "Immortalize Merb & services (cron job makes sure they keep running)"
  task :immortalize_daemons, :roles => :app do
    sudo "#{$IMMORTALIZE} --log-location /home/prod/.immortalize setup"
  end

  desc "Start Merb & services"
  task :start, :roles => :app do
    run "#{$IMMORTALIZE} --notify=rw-staging@mutuallyhuman.com run \"cd \\\"#{current_path}\\\"; #{$MERB} -e #{merb_env} -p 4000 1>>log/#{merb_env}.log 2>&1\""
    run "#{$IMMORTALIZE} --notify=rw-staging@mutuallyhuman.com run \"cd \\\"#{current_path}\\\"; #{$MERB} -e #{merb_env} -p 4001 -r bin/encoder.rb 1>>log/encoder.#{merb_env}.log 2>&1\""
    run "#{$IMMORTALIZE} --notify=rw-staging@mutuallyhuman.com run \"cd \\\"#{current_path}\\\"; #{$MERB} -e #{merb_env} -p 4002 -r bin/notifier.rb 1>>log/notifier.#{merb_env}.log 2>&1\""
  end
  
  desc "Stop Merb & services"
  task :stop, :roles => :app do
    run "#{$IMMORTALIZE} stop \"cd \\\"#{current_path}\\\"; #{$MERB} -e #{merb_env} -p 4000 1>>log/#{merb_env}.log 2>&1\""
    run "#{$IMMORTALIZE} stop \"cd \\\"#{current_path}\\\"; #{$MERB} -e #{merb_env} -p 4001 -r bin/encoder.rb 1>>log/encoder.#{merb_env}.log 2>&1\""
    run "#{$IMMORTALIZE} stop \"cd \\\"#{current_path}\\\"; #{$MERB} -e #{merb_env} -p 4002 -r bin/notifier.rb 1>>log/notifier.#{merb_env}.log 2>&1\""
  end

  desc "Restart Merb & services"
  task :restart, :roles => :app do
    run "#{$IMMORTALIZE} stop \"cd \\\"#{current_path}\\\"; #{$MERB} -e #{merb_env} -p 4000 1>>log/#{merb_env}.log 2>&1\""
    run "#{$IMMORTALIZE} --notify=rw-staging@mutuallyhuman.com run \"cd \\\"#{current_path}\\\"; #{$MERB} -e #{merb_env} -p 4000 1>>log/#{merb_env}.log 2>&1\""
    run "#{$IMMORTALIZE} stop \"cd \\\"#{current_path}\\\"; #{$MERB} -e #{merb_env} -p 4001 -r bin/encoder.rb 1>>log/encoder.#{merb_env}.log 2>&1\""
    run "#{$IMMORTALIZE} --notify=rw-staging@mutuallyhuman.com run \"cd \\\"#{current_path}\\\"; #{$MERB} -e #{merb_env} -p 4001 -r bin/encoder.rb 1>>log/encoder.#{merb_env}.log 2>&1\""
    run "#{$IMMORTALIZE} stop \"cd \\\"#{current_path}\\\"; #{$MERB} -e #{merb_env} -p 4002 -r bin/notifier.rb 1>>log/notifier.#{merb_env}.log 2>&1\""
    run "#{$IMMORTALIZE} --notify=rw-staging@mutuallyhuman.com run \"cd \\\"#{current_path}\\\"; #{$MERB} -e #{merb_env} -p 4002 -r bin/notifier.rb 1>>log/notifier.#{merb_env}.log 2>&1\""
  end
end
