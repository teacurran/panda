$LOAD_PATH.unshift(File.dirname(__FILE__))

# Config
# ======
require 'config'
# Load the user's config options
require File.dirname(__FILE__)+'/../config/panda.rb'
# TODO: move config store to sdb
Panda::Config.check

# Deps
# ====
require 'rubygems'
require 'fileutils'

# File store
# ==========
require 'store/abstract_store'
require 'store/file_store'
# TODO: store tmp clippings on S3 instead of locally so we can support clusters
# require 'store/local_store'

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

# Models
# ======
require 'db/video'
require 'db/profile'
require 'db/encoding'
