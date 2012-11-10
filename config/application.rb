require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Panda
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'


    config.api_key = "dfgdfgdfg"
    config.notification_email = "somoene@nothing.xxy"

    config.account_name   = "My Panda Account"

    config.private_tmp_path       = "videos"
    config.public_tmp_path        = "public/tmp"
    config.public_tmp_url         = "tmp"

    config.thumbnail_height_constrain = 125
    config.choose_thumbnail       = false

    config.notification_retries   = 6
    config.notification_frequency = 10


  # ================================================
  # AWS Details
  # ================================================

  # For S3 and SimpleDB:
  config.access_key_id         = "AWS_ACCESS_KEY"
  config.secret_access_key     = "AWS_SECRET_ACCESS_KEY"

  config.sdb_base_url           = "http://sdb.amazonaws.com/"

  # SimpleDB domains (you need only change these if you have multiple Panda
  # instances using your AWS account):
  # config.sdb_videos_domain]     = "panda_videos"
  # config.sdb_users_domain]      = "panda_users"
  # config.sdb_profiles_domain]   = "panda_profiles"
  config.sdb_videos_domain     = "SDBPREFIX_panda_videos"
  config.sdb_users_domain      = "SDBPREFIX_panda_users"
  config.sdb_profiles_domain   = "SDBPREFIX_panda_profiles"

  # ================================================
  # Thumbnail
  # ================================================
  # If you set this option you will be able to change the thumbnail for a
  # video after a video has been encoded. This many thumbnail options will
  # automatically be generated. The positions of these clipping will be
  # equally distributed throughout the video.

  # config.choose_thumbnail]      = 6

  # ================================================
  # Application notification
  # ================================================
  # Panda will send your application a notfication when a video has finished
  # encoding. If it fails it will retry notification_retries times. These
  # values are the defaults and should work for most applications.

  # config.notification_retries]  = 6
  # config.notification_frequency]= 10
  # config.state_update_url]      = "http://YOUR_APP/videos/:video_file_id/status_update"
  config.state_update_url      = "STATE_UPDATE_URL"

  # ================================================
  # Get emailed error messages
  # ================================================
  # If you want errors emailed to you, when an encoding fails or panda fails
  # to post a notification to your application, fill in both values:
  # config.notification_email]    = "me@mydomain.com"
  # config.noreply_from]          = "panda@mydomain.com"
  end
end

