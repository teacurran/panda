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
    
    @video_upload_hash = {:file =>
      Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__),'panda.mp4'), "application/octet-stream", true), 
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
    # creates encodings
    created_video_hash = JSON.parse(last_response.body)
    created_video_hash.should eql_hash({:duration => 14000, :width => 300, :height => 240, :fps => 29, :extname => '.mp4', :original_filename => 'panda.mp4', :video_codec => 'h264', :audio_codec => 'aac', :thumbnail_position => nil, :upload_redirect_url => 'http://localhost/upload_redirect_url/$id', :state_update_url => 'http://localhost/state_update_url/$id'})
    created_video = Video.find(created_video_hash['key'])
    puts created_video.encodings.first.to_hash.should eql_hash({:width => 320, :height => 240, :encoding_time => nil, :extname => '.flv', :status => 'queued', :video_id => created_video_hash['key'], :profile_id => @profile.key, :started_encoding_at => nil})
  end
  
  # it "posts /videos.json and requires all params"
  # 
  # it "posts /videos.json and requires file to be submitted"
  # it "posts /videos.json and requires "
  # it "posts /videos.json and recognises video format"
  # 
  # 
  # # it "posts /videos.json"
  # 
  # # Videos
  # 
  # it "gets /videos.json" do
  #   get "/videos.json"
  #   last_response.should be_ok
  #   JSON.parse(last_response.body).first.should eql_hash(@video_hash)
  # end
  # 
  # it "gets /videos/:key.json" do
  #   get "/videos/#{@video.key}.json"
  #   last_response.should be_ok
  #   JSON.parse(last_response.body).should eql_hash(@video_hash)
  # end
  # 
  # it "puts /videos/:key.json" do
  #   put "/videos/#{@video.key}.json", {:upload_redirect_url => "xxx"}
  #   last_response.should be_ok
  #   JSON.parse(last_response.body).should eql_hash(@video_hash.merge({:upload_redirect_url => "xxx"}))
  # end
  # 
  # it "puts /videos/:key.json but doesn't allow restricted params" do
  #   video = Video.create(@video_hash)
  #   put "/videos/#{video.key}.json", @video_hash.merge({:upload_redirect_url => "xxx", :original_filename => 'restricted value should not be saved'})
  #   last_response.should be_ok
  #   JSON.parse(last_response.body).should eql_hash(@video_hash.merge({:upload_redirect_url => "xxx"}))
  # end
  # 
  # it "deletes /videos/:key.json and its encodings" do
  #   video = Video.create(@video_hash)
  #   encoding = Encoding.create(@encoding_hash.merge(:video_id => video.key))
  #   delete "/videos/#{video.key}.json"
  #   Video.find(:all, :conditions => ["key=?",video.key]).size.should == 0
  #   Encoding.find(:all, :conditions => ["key=?",encoding.key]).size.should == 0
  #   last_response.should be_ok
  #   last_response.body.should == ''
  # end
  #   
  # # Profiles
  # 
  # it "gets /profiles.json" do
  #   get "/profiles.json"
  #   last_response.should be_ok
  #   JSON.parse(last_response.body).first.should eql_hash(@profile_hash)
  # end
  # 
  # it "gets /profiles/:key.json" do
  #   get "/profiles/#{@profile.key}.json"
  #   last_response.should be_ok
  #   JSON.parse(last_response.body).should eql_hash(@profile_hash)
  # end
  # 
  # it "posts /profiles.json" do
  #   post "/profiles.json", @profile_hash
  #   last_response.should be_ok
  #   JSON.parse(last_response.body).should eql_hash(@profile_hash)
  # end
  # 
  # it "posts /profiles.json and requires all params" do
  #   post "/profiles.json", {}
  #   last_response.status.should == 400
  #   JSON.parse(last_response.body).should eql_hash({:message => "All required parameters were not supplied", :error => "InvalidRequest"})
  # end
  # 
  # it "puts /profiles/:key.json" do
  #   put "/profiles/#{@profile.key}.json", @profile_hash
  #   last_response.should be_ok
  #   JSON.parse(last_response.body).should eql_hash(@profile_hash)
  # end
  # 
  # it "puts /profiles/:key.json but doesn't allow restricted params" do
  #   profile = Profile.create(@profile_hash)
  #   put "/profiles/#{profile.key}.json", @profile_hash.merge({:extname => ".xxx", :restricted_param => 'the_value'})
  #   last_response.should be_ok
  #   JSON.parse(last_response.body).should eql_hash(@profile_hash.merge({:extname => ".xxx"}))
  # end
  # 
  # it "doesn't delete /profiles/:key.json if it has encodings associated" do
  #   delete "/profiles/#{@profile.key}.json"
  #   Profile.find(:all, :conditions => ["key=?",@profile.key]).size.should == 1
  #   last_response.status.should == 422
  #   JSON.parse(last_response.body).should eql_hash({:message => "Couldn't delete Profile with ID=#{@profile.key} as it has associated encodings which must be deleted first", :error => "CannotDelete"})
  # end
  # 
  # it "deletes /profiles/:key.json" do
  #   profile = Profile.create(@profile_hash)
  #   delete "/profiles/#{profile.key}.json"
  #   Profile.find(:all, :conditions => ["key=?",profile.key]).size.should == 0
  #   last_response.should be_ok
  #   last_response.body.should == ''
  # end
  # 
  # # Generic errors
  # 
  # it "returns a 404" do
  #   get "/profiles/999.json"
  #   last_response.status.should == 404
  #   JSON.parse(last_response.body).should eql_hash({:message => "Couldn't find Profile with ID=999", :error => "RecordNotFound"})
  # end
  
end