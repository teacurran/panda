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
    
    @video_hash = {:duration => 99, :width => 320, :height => 240, :fps => 24, :extname => '.mp4', :original_filename => 'panda.mp4', :video_codec => 'h264', :audio_codec => 'aac', :thumbnail_position => '50', :upload_redirect_url => 'http://localhost/upload_redirect_url/$id', :state_update_url => 'http://localhost/state_update_url/$id'}
    @video = Video.create(@video_hash)
    
    @profile_hash = {:category => "Flash flv", :title => "Medium", :width => 320, :height => 240, :extname => ".flv", :command => "ffmpeg -i $input_file$ -ar 22050 -ab 64k -f flv -b 256k $resolution_and_padding$ -y $output_file$\nflvtool2 -U $output_file$"}
    @profile = Profile.create(@profile_hash)
  end
  
  # Videos
  
  it "gets /videos.json" do
    get "/videos.json"
    last_response.should be_ok
    JSON.parse(last_response.body).first.should eql_hash(@video_hash)
  end
  
  # Profiles
  
  it "gets /profiles.json" do
    get "/profiles.json"
    last_response.should be_ok
    JSON.parse(last_response.body).first.should eql_hash(@profile_hash)
  end
  
  it "gets /profiles/:key.json" do
    get "/profiles/#{@profile.key}.json"
    last_response.should be_ok
    JSON.parse(last_response.body).should eql_hash(@profile_hash)
  end

  it "posts /profiles.json" do
    post "/profiles.json", @profile_hash
    last_response.should be_ok
    JSON.parse(last_response.body).should eql_hash(@profile_hash)
  end
  
  it "posts /profiles.json and requires all params" do
    # lambda { post "/profiles.json", {} }.should raise_error(Panda::InvalidRequest)
    post "/profiles.json", {}
    last_response.status.should == 500
    last_response.body.should == "All required parameters were not supplied."
  end
  
  it "puts /profiles/key.json" do
    put "/profiles/#{@profile.key}.json", @profile_hash
    last_response.should be_ok
    JSON.parse(last_response.body).should eql_hash(@profile_hash)
  end
  
  it "puts /profiles/key.json but doesn't allow restricted params" do
    put "/profiles/#{@profile.key}.json", {:restricted_param => 'the_value'}
    # last_response.should be_ok
    # JSON.parse(last_response.body).should eql_hash(@profile_hash)
  end
  
end