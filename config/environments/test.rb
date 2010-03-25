puts "Loaded TEST Environment..."
Merb::BootLoader.after_app_loads do
  Merb::Mailer.delivery_method = :test_send
end

Panda::Config.use do |p|
  p[:sdb_videos_domain]     = "panda_local_panda_videos-test"
  p[:sdb_users_domain]      = "panda_local_panda_users-test"
  p[:sdb_profiles_domain]   = "panda_local_panda_profiles-test"
end
