Merb.logger.info("Loaded PRODUCTION Environment...")
Merb::Config.use { |c|
  c[:exception_details] = false
  c[:reload_classes] = false
  c[:log_level] = :info
  c[:log_file] = Merb.log_path + "/production.log"
}
Merb::BootLoader.after_app_loads do
  Merb::Mailer.delivery_method = :sendmail
end
