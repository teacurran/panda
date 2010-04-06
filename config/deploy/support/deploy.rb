namespace :deploy do
  desc "Restart Merb & services"
  task :restart do
    find_and_execute_task("immortalize:restart")
  end
end
