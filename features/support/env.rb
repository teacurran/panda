# Sets up the Merb environment for Cucumber (thanks to krzys and roman)
require "rubygems"
require 'ruby-debug'

# Add the local gems dir if found within the app root; any dependencies loaded
# hereafter will try to load from the local gems before loading system gems.
if (local_gem_dir = File.join(File.dirname(__FILE__), '..', 'gems')) && $BUNDLE.nil?
  $BUNDLE = true; Gem.clear_paths; Gem.path.unshift(local_gem_dir)
end

require "merb-core"
require 'spec/expectations'
require "merb_cucumber/world/webrat"

# Uncomment if you want transactional fixtures
# Merb::Test::World::Base.use_transactional_fixtures

# Quick fix for post features running Rspec error, see 
# http://gist.github.com/37930
def Spec.run? ; true; end

Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'cucumber')

Before do
  Video.query.each do |v|
    v.delete_from_store
    v.destroy!
  end
  Notification.all.each do |n|
    n.destroy!
  end
end
