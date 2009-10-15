$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'..'))
require 'rubygems'
require 'sinatra/base'
Sinatra::Base.set :environment, :test
Sinatra::Base.set :raise_errors, false
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
    
    @encoding_hash = {:width => 320, :height => 240, :encoding_time => 9, :extname => '.flv', :status => 'queued', :video_id => @video.id, :profile_id => @profile.id, :started_encoding_at => nil, :encoding_progress => nil}
    @encoding = Encoding.create(@encoding_hash)
  end
  
  def request_with_auth(verb, request_uri, params_given={})
    params = params_given.dup
    params[:access_key] = Panda::Config[:access_key]
    params[:timestamp] = Time.now.iso8601
    
    params_without_file = params.dup
    params_without_file.delete(:file)
    
    params[:signature] = Panda::ApiAuthentication.authenticate(verb.to_s.upcase, request_uri, 'example.org', Panda::Config[:secret_key], params_without_file)
    
    if verb == :get or verb == :delete
      send(verb, Panda::ApiAuthentication.add_params_to_request_uri(request_uri, params))
    else
      send(verb, request_uri, params)
    end
  end
  
  # Video upload
  
  it "posts /videos.json and also create encodings" do
    request_with_auth(:post, "/videos.json", @video_upload_hash.merge({:upload_key => UUID.timestamp_create().to_s}))
    
    last_request.POST["file"][:filename].should == "panda.mp4"
    last_request.POST["file"][:type].should == "application/octet-stream"
    last_response.should be_ok
    # TODO: test windows filenames stripiing
    created_video_hash = JSON.parse(last_response.body)
    created_video_hash.should eql_hash({:duration => 14000, :width => 300, :height => 240, :fps => 29, :extname => '.mp4', :original_filename => 'panda.mp4', :video_codec => 'h264', :audio_codec => 'aac', :thumbnail_position => nil, :upload_redirect_url => 'http://localhost/upload_redirect_url/$id', :state_update_url => 'http://localhost/state_update_url/$id'})
    
    request_with_auth(:get, "/videos/#{created_video_hash['id']}/encodings.json")
    created_encoding_hash = JSON.parse(last_response.body).first
    created_encoding_hash.should eql_hash({:width => 320, :height => 240, :encoding_time => nil, :extname => '.flv', :status => 'queued', :video_id => created_video_hash['id'], :profile_id => @profile.id, :started_encoding_at => nil, :encoding_progress => nil})
    
    Video.find(created_video_hash['id']).obliterate!
  end
  
  it "posts /videos.json and requires all params" do
    request_with_auth(:post, "/videos.json", {:file => Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__),'panda.mp4'), "application/octet-stream", true), :upload_key => UUID.timestamp_create().to_s})
    last_response.status.should == 400
    JSON.parse(last_response.body).should eql_hash({:message => "All required parameters were not supplied: upload_key, upload_redirect_url, state_update_url", :error => "BadRequest"})
  end
  
  it "posts /videos.json and requires file to be submitted" do
    request_with_auth(:post, "/videos.json", @video_upload_hash.merge({:file => nil, :upload_key => UUID.timestamp_create().to_s}))
    last_response.status.should == 400
    JSON.parse(last_response.body).should eql_hash({:message => "No file was submitted", :error => "NoFileSubmitted"})
  end
  
  it "posts /videos.json and doesn't recognise video format" do
    request_with_auth(:post, "/videos.json", @video_upload_hash.merge({:file => Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__),'not_valid_video.mp4'), "application/octet-stream", true), :upload_key => UUID.timestamp_create().to_s}))
    last_response.status.should == 422
    JSON.parse(last_response.body).should eql_hash({:message => "Video data in file not recognized", :error => "FormatNotRecognised"})
  end
  
  it "posts /videos.json and requires a file extension" do
    request_with_auth(:post, "/videos.json", @video_upload_hash.merge({:file => Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__),'not_valid_video'), "application/octet-stream", true), :upload_key => UUID.timestamp_create().to_s}))
    last_response.status.should == 422
    JSON.parse(last_response.body).should eql_hash({:message => "Filename has no extension", :error => "FormatNotRecognised"})
  end
  
  # Videos
  
  it "gets /videos.json" do
    request_with_auth(:get, "/videos.json")
    last_response.should be_ok
    JSON.parse(last_response.body).first.should eql_hash(@video_hash)
  end
  
  it "gets /videos/:id.json" do
    request_with_auth(:get, "/videos/#{@video.id}.json")
    last_response.should be_ok
    JSON.parse(last_response.body).should eql_hash(@video_hash)
  end
    
  it "gets /videos/upload/:upload_key.json" do
    request_with_auth(:get, "/videos/upload/#{@video.upload_key}.json")
    last_response.should be_ok
    JSON.parse(last_response.body).should eql_hash(@video_hash)
  end
  
  it "puts /videos/:id.json" do
    request_with_auth(:put, "/videos/#{@video.id}.json", {:upload_redirect_url => "xxx"})
    last_response.should be_ok
    JSON.parse(last_response.body).should eql_hash(@video_hash.merge({:upload_redirect_url => "xxx"}))
  end
  
  it "puts /videos/:id.json but doesn't allow restricted params" do
    video = Video.create(@video_hash)
    request_with_auth(:put, "/videos/#{video.id}.json", @video_hash.merge({:upload_redirect_url => "xxx", :original_filename => 'restricted value should not be saved'}))
    last_response.should be_ok
    JSON.parse(last_response.body).should eql_hash(@video_hash.merge({:upload_redirect_url => "xxx"}))
  end
  
  it "deletes /videos/:id.json and its encodings" do
    video = Video.create(@video_hash)
    encoding = Encoding.create(@encoding_hash.merge(:video_id => video.id))
    request_with_auth(:delete, "/videos/#{video.id}.json")
    Video.find(:all, :conditions => ["id=?",video.id]).size.should == 0
    Encoding.find(:all, :conditions => ["id=?",encoding.id]).size.should == 0
    last_response.should be_ok
    last_response.body.should == ''
  end
  
  # Encodings
  
  it "gets /encodings.json" do
    request_with_auth(:get, "/encodings.json")
    last_response.should be_ok
    JSON.parse(last_response.body).first.should eql_hash(@encoding_hash)
  end
  
  it "gets /encodings.json?status=:status" do
    request_with_auth(:get, "/encodings.json?status=error")
    last_response.should be_ok
    Encoding.find(:all, :conditions => ["status=?",'error']).size.should == 0
    
    request_with_auth(:get, "/encodings.json?status=queued")
    last_response.should be_ok
    JSON.parse(last_response.body).first.should eql_hash(@encoding_hash)
  end
  
  it "gets /encodings/:id.json" do
    request_with_auth(:get, "/encodings/#{@encoding.id}.json")
    last_response.should be_ok
    JSON.parse(last_response.body).should eql_hash(@encoding_hash)
  end
  
  it "posts /encodings.json" do
    request_with_auth(:post, "/encodings.json", {:video_id => @video.id, :profile_id => @profile.id})
    last_response.should be_ok
    encoding_hash = JSON.parse(last_response.body)
    encoding_hash.should eql_hash(@encoding_hash.merge({:encoding_time => nil}))
    Encoding.find(:all).size.should == 2
    Encoding.find(encoding_hash['id']).obliterate!
  end
  
  it "posts /encodings.json and requires all params" do
    request_with_auth(:post, "/encodings.json", {})
    last_response.status.should == 400
    JSON.parse(last_response.body).should eql_hash({:message => "All required parameters were not supplied: video_id, profile_id", :error => "BadRequest"})
  end
  
  it "puts /encodings/:id/retry.json and allows encoding to be retried"
  
  it "deletes /encodings/:id.json" do
    encoding = Encoding.create(@encoding_hash)
    request_with_auth(:delete, "/encodings/#{encoding.id}.json")
    Encoding.find(:all, :conditions => ["id=?",encoding.id]).size.should == 0
    last_response.should be_ok
    last_response.body.should == ''
  end
  
  # Profiles
  
  it "gets /profiles.json" do
   request_with_auth(:get, "/profiles.json")
   last_response.should be_ok
   JSON.parse(last_response.body).first.should eql_hash(@profile_hash)
  end
  
  it "gets /profiles/:id.json" do
   request_with_auth(:get, "/profiles/#{@profile.id}.json")
   last_response.should be_ok
   JSON.parse(last_response.body).should eql_hash(@profile_hash)
  end
  
  it "gets /profiles/:id/encodings.json" do
   request_with_auth(:get, "/profiles/#{@profile.id}/encodings.json")
   last_response.should be_ok
   JSON.parse(last_response.body).first.should eql_hash(@encoding_hash)
  end
  
  it "posts /profiles.json" do
   request_with_auth(:post, "/profiles.json", @profile_hash)
   last_response.should be_ok
   JSON.parse(last_response.body).should eql_hash(@profile_hash)
  end
  
  it "posts /profiles.json and requires all params" do
   request_with_auth(:post, "/profiles.json", {})
   last_response.status.should == 400
   JSON.parse(last_response.body).should eql_hash({:message => "All required parameters were not supplied: width, height, category, title, extname, command", :error => "BadRequest"})
  end
  
  it "puts /profiles/:id.json" do
   request_with_auth(:put, "/profiles/#{@profile.id}.json", @profile_hash)
   last_response.should be_ok
   JSON.parse(last_response.body).should eql_hash(@profile_hash)
  end
  
  it "puts /profiles/:id.json but doesn't allow restricted params" do
   profile = Profile.create(@profile_hash)
   request_with_auth(:put, "/profiles/#{profile.id}.json", @profile_hash.merge({:extname => ".xxx", :restricted_param => 'the_value'}))
   last_response.should be_ok
   JSON.parse(last_response.body).should eql_hash(@profile_hash.merge({:extname => ".xxx"}))
  end
  
  it "doesn't delete /profiles/:id.json if it has encodings associated" do
   request_with_auth(:delete, "/profiles/#{@profile.id}.json")
   Profile.find(:all, :conditions => ["id=?",@profile.id]).size.should == 1
   last_response.status.should == 422
   JSON.parse(last_response.body).should eql_hash({:message => "Couldn't delete Profile with ID=#{@profile.id} as it has associated encodings which must be deleted first", :error => "CannotDelete"})
  end
  
  it "deletes /profiles/:id.json" do
   profile = Profile.create(@profile_hash)
   request_with_auth(:delete, "/profiles/#{profile.id}.json")
   Profile.find(:all, :conditions => ["id=?",profile.id]).size.should == 0
   last_response.should be_ok
   last_response.body.should == ''
  end
  
  # Generic errors
  
  it "returns a 404" do
   request_with_auth(:get, "/profiles/999.json")
   last_response.status.should == 404
   JSON.parse(last_response.body).should eql_hash({:message => "Couldn't find Profile with ID=999", :error => "RecordNotFound"})
  end

end