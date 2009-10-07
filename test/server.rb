$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'..'))
require 'rubygems'
require 'sinatra/base'
Sinatra::Base.set :environment, :test
PANDA_ENV = :test
require 'lib/server'

require 'spec'
require 'rack/test'
require 'test/spec_eql_hash'

Spec::Runner.configure do |conf|
  conf.include Rack::Test::Methods
end
describe 'API' do
  def app
    Panda::Server
  end
  
  before do
    [Video, Encoding, Profile].each {|m| m.find(:all).each {|v| v.delete } }
  end
  
  it "says hello" do
    Video.create(:duration => 99, :width => 320, :height => 240, :fps => 24, :extname => '.mp4', :original_filename => 'panda.mp4', :video_codec => 'h264', :audio_codec => 'aac', :thumbnail_position => '50', :upload_redirect_url => 'http://localhost/upload_redirect_url/$id', :state_update_url => 'http://localhost/state_update_url/$id')
    
    get '/videos.json'
    last_response.should be_ok
    JSON.parse(last_response.body).first.should eql_hash({'id' => :any_value, 'key' => :any_value, 'created_at' => :any_value, 'updated_at' => :any_value, 'duration' => 99, 'width' => 320, 'height' => 240, 'fps' => 24, 'extname' => '.mp4', 'original_filename' => 'panda.mp4', 'video_codec' => 'h264', 'audio_codec' => 'aac', 'thumbnail_position' => '50', 'upload_redirect_url' => 'http://localhost/upload_redirect_url/$id', 'state_update_url' => 'http://localhost/state_update_url/$id'})
  end
end