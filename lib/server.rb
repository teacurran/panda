$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'..'))
require 'sinatra/base'
require 'json'
require 'lib/panda'
require 'lib/run_later'

module Panda
  class InvalidRequest < StandardError; end
  
  class Server < Sinatra::Base
    # TODO: Auth similar to Amazon where we hash all the form params plus the api key and send a signature
    
    # mime :json, "application/json"
        
    def display_response(object, ext)
      case ext.to_sym
      when :json
        content_type :json
        object.to_json
      when :xml
        content_type :xml
        object.to_xml
      end
    end
    
    def ajax_response(object)
      "<textarea>" + object.to_json + "</textarea>"
    end
    
    def required_params(params, *params_list)
      params_list.each do |p|
        raise InvalidRequest unless params.has_key?(p.to_s)
      end
    end
    
    # Videos
    
    get '/videos.*' do
      
    end
    
    # HTML uplaod method where video data is uploaded directly
    post '/videos' do
      begin
        required_params(params, :upload_redirect_url, :state_update_url)
        
        video = Video.create_from_upload(params[:file], params[:state_update_url],  params[:upload_redirect_url])
        
        # run_later do # TODO: ensure run_later timeout is long enough
          video.upload_to_store
          video.queue_encodings
        # end
        
        status 200
        ajax_response(:location => video.get_upload_redirect_url)
      rescue InvalidRequest => e
        status 400
        ajax_response(:error => e.to_s)
      rescue Video::VideoError => e
        status 422
        ajax_response(:error => e.to_s.gsub(/Video::/,""))
      rescue => e
        raise e
        status 500
        ajax_response(:error => "InternalServerError")
      end
    end
    
    # post '/videos.*' do
      # begin
        # required_params(params, :state_update_url)
        # 
        # video = Video.create_from_upload(params[:file], params[:state_update_url])
        # video.upload_to_store
        # video.queue_encodings
        # 
        # status 200
        # response video, params[:splat].first
        # TODO: handle errors with Sinatra's error blocks
        
      # rescue Video::NotValid
      #   status 422
      # rescue Video::VideoError
      #   status 500
      # end
    # end
    
    # Profiles
    
    get '/profiles.*' do
      display_response(Profile.find(:all), params[:splat].first)
    end
    
    get '/profiles/:key.*' do
      display_response(Profile.find(params[:key]), params[:splat].first)
    end
    
    post '/profiles.*' do
      required_params(params, :width, :height :category, :title, :extname, :command)
      profile = Profile.create()
      display_response(profile, params[:splat].first)
    end
    
    put '/profiles/:key.*' do
      profile = Profile.find(params[:key])
      profile.update_attributes(select_params(params, Profile.writeable_attributes))
      display_response(profile, params[:splat].first)
    end
    
    delete '/profiles/:key.*' do 
      profile = Profile.find(params[:key])
      profile.destroy!
      status 200
    end
  end
end

# run Panda::Core