puts "Loaded CUCUMBER Environment..."

Merb::Config.use { |c|
  c[:exception_details] = false
  c[:reload_classes] = false
  c[:log_level] = :info
  c[:log_file] = Merb.log_path + "/cucumber.log"
}

Merb::BootLoader.after_app_loads do
  Merb::Mailer.delivery_method = :test_send
end

Panda::Config.use do |p|
  p[:sdb_videos_domain]     = "panda_local_panda_videos-test"
  p[:sdb_users_domain]      = "panda_local_panda_users-test"
  p[:sdb_profiles_domain]   = "panda_local_panda_profiles-test"
end

$FFMPEG = '/usr/local/bin/ffmpeg'
