source 'https://rubygems.org'

gem 'rails', '3.2.8'

gem 'sqlite3'
gem 'do_sqlite3'
gem 'aws-sdk'

# thin webserver
gem 'thin'


# needed for koala if we are runnign on ruby 1.8
platform :ruby_18 do
  #gem "system_timer", "~> 1.2.4"
end


group :development do
  gem 'heroku_san'
end

group :stage do
end

group :production do
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'cucumber'

# below is from merb project - figure out what ones we need.
#gem "rubigen"

#gem "merb-assets"
#gem "merb-mailer"
#gem "merb_helpers"

gem "uuid"

#gem "amazon_sdb"
gem "dm-core"
gem "dm-migrations"
gem "dm-types"


gem "mhs-rvideo"

#gem "immortalize"
