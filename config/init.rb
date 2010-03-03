# Make the app's "gems" directory a place where gems are loaded from
Gem.clear_paths
Gem.path.unshift(Merb.root / "gems")

# Autoload from lib
$LOAD_PATH.unshift(Merb.root / "lib")
Merb.push_path(:lib, Merb.root / "lib") # uses **/*.rb as path glob.

require 'ruby-debug'

Merb::Config.use do |c|
  c[:session_id_key] = 'panda'
  c[:session_secret_key]  = '4d5e9b90d9e92c236a2300d718059aef3a9b9cbe'
  c[:session_store] = 'cookie'
end

# Load Panda config
require "config" / "panda_init"

# Gem dependencies
dependency 'merb-assets'
dependency 'merb-mailer'
dependency 'merb_helpers'
dependency 'uuid'

dependency 'amazon_sdb'
dependency 'dm-core'
dependency 'dm-migrations'
dependency 'dm-types'
dependency 'do_sqlite3'

dependency 'activesupport'
dependency 'mhs-rvideo', :require_as => 'rvideo'
dependency 'aws-s3', :require_as => 'aws/s3'

# Dependencies in lib - not autoloaded in time so require them explicitly
require 's3_store'
require 'simple_db'
require 'local_store'

Merb::BootLoader.after_app_loads do
  DataMapper.setup(:default, YAML.load_file("config/database.yml")[Merb.environment.to_sym])
  Notification.auto_upgrade!

  # Check panda config
  Panda::Config.check
  
  unless Merb.environment == "test"
    require "config" / "aws"
    Panda::Setup.create_sdb_domains # This can run many times, it doesn't re-create them.
    # Create an encoding profile. More can be found at the first url at the top of this document.
    # Using new().save form (explicitly setting the record-key) allows us to run this as many
    # times as we want and it just creates the same record.
    Profile.new('Flash video SD',
      :title => "Flash video SD",
      :container => "flv",
      :video_bitrate => 300,
      :audio_bitrate => 48,
      :width => 320,
      :height => 240,
      :fps => 24,
      :position => 0,
      :player => "flash"
    ).save
  end
  
  Store = case Panda::Config[:videos_store]
  when :s3
    S3Store.new
  when :filesystem
    FileStore.new
  else
    raise RuntimeError, "You have specified an invalid videos_store configuration option. Valid options are :s3 and :filesystem"
  end
  
  if Panda::Config[:notification_email].nil? or Panda::Config[:noreply_from].nil?
    Merb.logger.warn "No notification_email or noreply_from set in panda_init.rb - so errors will only written to the log and not emailed."
  end
  
  LocalStore.ensure_directories_exist
  
  begin
    Profile.warn_if_no_encodings unless Merb.env == 'test'
  rescue Amazon::SDB::ParameterError
    Merb.logger.info "PANDA WARNING: Profile simple db domain does not exist. Please check that you have created all the required domains (see the getting started guide)."
  end
end
