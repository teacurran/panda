require 'config'
# TODO: move config store to sdb
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../config/panda.rb')
Panda::Config.check

# File store
# ==========
require 'abstract_store'
require 'file_store'
require 's3_store'
require 'local_store'

Store = case Panda::Config[:videos_store]
when :s3
  S3Store.new
when :filesystem
  FileStore.new
else
  raise RuntimeError, "You have specified an invalid videos_store configuration option. Valid options are :s3 and :filesystem"
end

LocalStore.ensure_directories_exist

# Models
# ======
require 'sdb/video'

# SimpleDB
# ========
SimpleRecord::Base.set_domain_prefix(Panda::Config[:sdb_domain_prefix]) if Panda::Config[:sdb_domain_prefix]
SimpleRecord.establish_connection(Panda::Config[:access_key_id],Panda::Config[:secret_access_key])