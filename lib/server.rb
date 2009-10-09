require 'lib/panda'
require 'run_later'

module Panda
  class InvalidRequest < StandardError; end
  class RecordNotFound < StandardError; end
  class CannotDelete < StandardError; end
  
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
        r = object.to_json
      # when :xml
      #   content_type :xml
      #   r = object.to_xml
      else
        raise InvalidRequest, "Currently only .json is supported as a format"
      end
      
      r = "<textarea>#{r}</textarea>" if request.env['panda.iframe']
      return r
    end
    
    # Errors
    
    def display_error(s)
      status s
      # TODO: support xml in returned error messages
      r = {:error => request.env['sinatra.error'].class.to_s.split('::').last, :message => request.env['sinatra.error'].message}
      display_response(r, :json)
    end
    
    error do
      display_error 500
    end
    
    error ActiveRecord::RecordNotFound do
      display_error 404
    end
    
    error InvalidRequest do
      display_error 400
    end
    
    error Video::VideoError do
      display_error 422
    end
    
    error CannotDelete do
      display_error 422
    end
    
    # Params
    
    def required_params(params, *params_list)
      params_list.each do |p|
        raise(InvalidRequest, "All required parameters were not supplied") unless params.has_key?(p.to_s)
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
      display_response Video.find(:all), params[:splat].first
    end
    
    # HTML uplaod method where video data is uploaded directly
    # This is the only method which allows ajax submittion. If it's submitted by ajax we must wrap the response in <textarea> tags
    post '/videos' do
      puts request.env.inspect
      request.env['panda.iframe'] = params[:iframe].to_bool
      
      required_params(params, :upload_redirect_url, :state_update_url)
      
      video = Video.create_from_upload(params[:file], params[:state_update_url],  params[:upload_redirect_url])
      
      # run_later do # TODO: ensure run_later timeout is long enough
        video.upload_to_store
        video.queue_encodings
      # end
      
      if request.env['panda.iframe']
        display_response({:location => video.get_upload_redirect_url}, :json)
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
      raise(CannotDelete, "Couldn't delete Profile with ID=#{params[:key]} as it has associated encodings which must be deleted first") unless profile.encodings.empty?
      profile.destroy
      status 200
    end
  end
end

# run Panda::Core