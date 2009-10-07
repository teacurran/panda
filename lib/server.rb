require 'lib/panda'
require 'run_later'

module Panda
  class InvalidRequest < StandardError; end
  
  class Server < Sinatra::Base
    configure(:test) do
      set :raise_errors, false
    end
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
    
    def ajax_response(r)
      "<textarea>" + r.to_json + "</textarea>"
    end
    
    # Errors
    
    def display_error(e)
      # TODO: support xml in returned error messages
      r = {:error => e.class.to_s, :message => e.message}
      if ajax_request?
        
    end
    
    error do
      display_error(request.env['sinatra.error'])
    end
        
    error InvalidRequest do
      status 400
      display_error(request.env['sinatra.error'])
    end
    
    error Video::VideoError do
      status 422
      display_error(request.env['sinatra.error'])
    end
    
    # Params
    
    def required_params(params, *params_list)
      params_list.each do |p|
        raise(InvalidRequest, "All required parameters were not supplied.") unless params.has_key?(p.to_s)
      end
    end
    
    def select_params(params, *params_list)
      only_selected_params = {}
      params_list.each do |p|
        only_selected_params[p] = params[p] if params.has_key?(p.to_s)
      end
      return only_selected_params
    end
    
    # Videos
    
    get '/videos.*' do
      raise request.env.inspect
      display_response Video.find(:all), params[:splat].first
    end
    
    # HTML uplaod method where video data is uploaded directly
    post '/videos' do
      required_params(params, :upload_redirect_url, :state_update_url)
      
      video = Video.create_from_upload(params[:file], params[:state_update_url],  params[:upload_redirect_url])
      
      # run_later do # TODO: ensure run_later timeout is long enough
        video.upload_to_store
        video.queue_encodings
      # end
      
      if ajax_request?
        ajax_response({:location => video.get_upload_redirect_url})
      else
        redirect video.get_upload_redirect_url
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
      required_params(params, :width, :height, :category, :title, :extname, :command)
      profile = Profile.create(select_params(params, :width, :height, :category, :title, :extname, :command))
      display_response(profile, params[:splat].first)
    end
    
    put '/profiles/:key.*' do
      profile = Profile.find(params[:key])
      profile.update_attributes(select_params(params, :width, :height, :category, :title, :extname, :command))
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