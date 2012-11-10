Panda::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  
  
  # config.account_name          = "OPTIONAL_STRING_TO_IDENTIFY_PANDA_INSTANCE"
  
  # ================================================
  # API integration options
  # ================================================
  # The api_key allows your application to authenticate with Panda. You should 
  # generate a random string to use as the key.
  
  config.api_key               = "SECRET_KEY_FOR_PANDA_API"
  config.upload_redirect_url   = "http://127.0.0.1:3000/videos/:video_file_id/uploaded"
  
  # ============================================================
  # Local storage. Public should be accessible from the internet
  # ============================================================
  
  #config.private_tmp_path      = "public/tmp/videos"
  # Defaults to tmp within the Panda public directory. Optionally configurable
  # config.public_tmp_path]       = "/var/www/images"
  # config.public_tmp_url]        = "http://images.app.com"
  
  # ================================================
  # Storage location for uploaded and encoded videos
  # ================================================
  
  # true = s3, false = filesystem
  # config.use_s3] = true
  config.use_s3 = false

  if config.use_s3
    # For S3 storage:
    config.videos_store          = 'S3'
    config.videos_domain         = "s3.amazonaws.com/S3_BUCKET"
    config.s3_videos_bucket      = "S3_BUCKET"
  else
    # For local filesystem storage:
    config.videos_store          = 'filesystem'
    # config.videos_domain]         = "localhost:4000/store"
    config.videos_domain         = "VIDEOS_DOMAIN/store"
    #config.public_videos_dir     = "public/store"
  end
  
  config.FFMPEG = '/usr/local/bin/ffmpeg'
  
end
