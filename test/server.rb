$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'..'))
require 'lib/server'
require 'spec'
require 'rack/test'

set :environment, :test

Spec::Runner.configure do |conf|
  conf.include Rack::Test::Methods
end

describe 'API' do
  def app
    Panda::Server
  end

  it "says hello" do
    get '/videos.json'
    last_response.should be_ok
    last_response.body.should == 'Hello World'
  end
end