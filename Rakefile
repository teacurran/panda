desc "Load env"
task :environment do
  PANDA_ENV = ENV['PANDA_ENV'].to_sym
  require 'lib/panda'
end

namespace :db do
  desc "Migrate the database"
    task(:migrate => :environment) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
  end
end