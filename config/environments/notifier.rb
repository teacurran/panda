Merb.logger.info("Loaded NOTIFIER Environment...")
Merb::Config.use { |c|
  c[:exception_details] = true
  c[:log_auto_flush ] = true
  c[:reload_classes] = false
  c[:log_level] = :info
  c[:log_file] = Merb.log_path + "/notifier.log"
}
Merb::BootLoader.after_app_loads do
  Merb::Mailer.delivery_method = :sendmail
end

Panda::Config.use do |p|
  p[:sdb_videos_domain]     = "panda_local_panda_videos"
  p[:sdb_users_domain]      = "panda_local_panda_users"
  p[:sdb_profiles_domain]   = "panda_local_panda_profiles"
end
