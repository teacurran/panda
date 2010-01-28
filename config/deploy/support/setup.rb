desc "Create shared config directory and default panda_init.rb."
task :create_shared_config do
  run "mkdir -p #{shared_path}/config"
  put File.read("config/panda_init.rb.example"), "#{shared_path}/config/panda_init.rb"
  put File.read("config/mailer.rb.example"), "#{shared_path}/config/mailer.rb"
end
