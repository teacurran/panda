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
    
    @video_upload_hash = {:file => Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__),'panda.mp4'), "application/octet-stream", true), 
      :upload_redirect_url => 'http://localhost/upload_redirect_url/$id',
      :state_update_url => 'http://localhost/state_update_url/$id' }
    
    @profile_hash = {:category => "Flash flv", :title => "Medium", :width => 320, :height => 240, :extname => ".flv", :command => "ffmpeg -i $input_file$ -ar 22050 -ab 64k -f flv -b 256k $resolution_and_padding$ -y $output_file$\nflvtool2 -U $output_file$"}
    @profile = Profile.create(@profile_hash)
    
    @encoding_hash = {:width => 320, :height => 240, :encoding_time => 9, :extname => '.mp4', :status => 'queued', :video_id => @video.key, :profile_id => @profile.key, :started_encoding_at => Time.now}
    @encoding = Encoding.create(@encoding_hash)
  end
  
  # Video upload
  
  it "posts /videos.json" do
    post "/videos.json", @video_upload_hash
    
    last_request.POST["file"][:filename].should == "panda.mp4"
    last_request.POST["file"][:type].should == "application/octet-stream"
    last_response.should be_ok
    # TODO: test windows filenames stripiing
    puts last_response.body
    created_video_hash = JSON.parse(last_response.body)
    created_video_hash.should eql_hash({:duration => 14000, :width => 300, :height => 240, :fps => 29, :extname => '.mp4', :original_filename => 'panda.mp4', :video_codec => 'h264', :audio_codec => 'aac', :thumbnail_position => nil, :upload_redirect_url => 'http://localhost/upload_redirect_url/$id', :state_update_url => 'http://localhost/state_update_url/$id'})
    
    get "/videos/#{created_video_hash['key']}/encodings.json"
    JSON.parse(last_response.body).first.should eql_hash({:width => 320, :height => 240, :encoding_time => nil, :extname => '.flv', :status => 'queued', :video_id => created_video_hash['key'], :profile_id => @profile.key, :started_encoding_at => nil})
  end
  
  it "posts /videos.json and requires all params" do
    post "/videos.json", {:file => Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__),'panda.mp4'), "application/octet-stream", true)}
    last_response.status.should == 400
    JSON.parse(last_response.body).should eql_hash({:message => "All required parameters were not supplied", :error => "BadRequest"})
  end
  
  it "posts /videos.json and requires file to be submitted" do
    post "/videos.json", @video_upload_hash.merge({:file => nil})
    last_response.status.should == 400
    JSON.parse(last_response.body).should eql_hash({:message => "No file was submitted", :error => "NoFileSubmitted"})
  end
  
  it "posts /videos.json and doesn't recognise video format" do
    post "/videos.json", @video_upload_hash.merge({:file => Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__),'not_valid_video.mp4'), "application/octet-stream", true)})
    last_response.status.should == 422
    JSON.parse(last_response.body).should eql_hash({:message => "Video data in file not recognised", :error => "FormatNotRecognised"})
  end
  
  it "posts /videos.json and requires a file extension" do
    post "/videos.json", @video_upload_hash.merge({:file => Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__),'not_valid_video'), "application/octet-stream", true)})
    last_response.status.should == 422
    JSON.parse(last_response.body).should eql_hash({:message => "Filename has no extension", :error => "FormatNotRecognised"})
  end
  
end