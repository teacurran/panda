$LOAD_PATH.unshift(File.dirname(__FILE__))

# Config
# ======
require 'panda/config'
# TODO: move config store to sdb
Panda::Config.load
Panda::Config.check

# Deps
# ====
require 'aasm'
require 'fileutils'
require 'rvideo'

# File store
# ==========
require 'store/abstract_store'
require 'store/file_store'
# TODO: store tmp clippings on S3 instead of locally so we can support clusters
require 'store/local_store'

Storage = case Panda::Config[:videos_store]
when :s3
  require 'aws/s3'
  require 'store/s3_store'
  S3Store.new
when :filesystem
  FileStore.new
else
  raise RuntimeError, "You have specified an invalid videos_store configuration option. Valid options are :s3 and :filesystem"
end

# LocalStore.ensure_directories_exist

# Database
# ========
case Panda::Config[:database]
when :simpledb
  require 'simple_record'
  
  SimpleRecord::Base.set_domain_prefix(Panda::Config[:sdb_domain_prefix])
  SimpleRecord.establish_connection(Panda::Config[:access_key_id],Panda::Config[:secret_access_key])
when :mysql
  raise "TODO: MySQL models and config"
end

require 'panda/core'
