$LOAD_PATH.unshift(File.dirname(__FILE__))

# Config
# ======

require 'config'
Panda::Config.environment = PANDA_ENV
require 'config/panda' # User's config
Panda::Config.check

# Deps
# ====

require 'fileutils'
require 'aasm'
require 'rvideo'
require 'logger'
require 'json'

require 'core_extensions/kernel'
require 'core_extensions/string'

# Logger
# ======
Log = Logger.new("log/server.log") # or log/development.log, whichever you prefer
Log.level  = Logger::INFO
# I'm assuming the other logging levels are debug &amp; error, couldn't find documentation on the different levels though
Log.info "Panda server has started. #{Time.now}"

# File store
# ==========
require 'store/abstract_store'
require 'store/file_store'
# TODO: store tmp clippings on S3 instead of locally so we can support clusters

Store = case Panda::Config[:videos_store]
when :s3
  require 'aws/s3'
  require 'store/s3_store'
  S3Store.new
when :filesystem
  FileStore.new
else
  raise RuntimeError, "You have specified an invalid videos_store configuration option. Valid options are :s3 and :filesystem"
end

# Database
# ========
case Panda::Config[:database]
when :simpledb
  require 'simple_record'
  require 'db/id_compatebility/sr.rb'
  
  SimpleRecord::Base.set_domain_prefix(Panda::Config[:sdb_domain_prefix])
  SimpleRecord.establish_connection(Panda::Config[:access_key_id],Panda::Config[:secret_access_key])
when :sqlite
  require 'uuid'
  require 'activerecord'
  require 'db/id_compatebility/ar.rb'
  
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :dbfile =>  Panda::Config[:sqlite_dbfile]
  )
when :mysql
  require 'uuid'
  require 'activerecord'
  require 'db/id_compatebility/ar.rb'
  
  raise "TODO: MySQL config and conneciton"
else
  raise RuntimeError, "You have specified an invalid database configuration option. Valid options are :simpledb, :mysql and :sqlite"
end

# Models
# ======
require 'db/video'
require 'db/profile'
require 'db/encoding'
