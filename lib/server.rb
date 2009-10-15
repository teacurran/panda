require 'lib/panda'
require 'run_later'

module Panda
  class BadRequest < StandardError; end
  class RecordNotFound < StandardError; end
  class CannotDelete < StandardError; end
  class NotAuthorized < StandardError; end
  
  class Server < Sinatra::Base
    # TODO: Auth similar to Amazon where we hash all the form params plus the api key and send a signature
    
    # mime :json, "application/json"
        
    def display_response(object, ext)
      if request.env['panda.iframe']
        content_type :html
        return "<textarea>#{object.to_json}</textarea>"
      else
        case ext.to_sym
        when :json
          content_type :json
          return object.to_json
        # when :xml
        #   content_type :xml
        #   r = object.to_xml
        else
          raise BadRequest, "Currently only .json is supported as a format"
        end
      end
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
    
    error NotAuthorized do
      display_error 401
    end
    
    if Panda::Config[:database] == :sqlite or Panda::Config[:database] == :mysql
      error ActiveRecord::RecordNotFound do
        display_error 404
      end
    end
    
    error BadRequest do
      display_error 400
    end
    
    error Video::FormatNotRecognised do
      display_error 422
    end
    
    error Video::NoFileSubmitted do
      display_error 400
    end
    
    error CannotDelete do
      display_error 422
    end
    
    # Params
    
    def required_params(params, *params_list)
      params_list.each do |p|
        raise(BadRequest, "All required parameters were not supplied: #{params_list.join(', ')}") unless params.has_key?(p.to_s)
      end
    end
    
    def select_params(params, *params_list)
      only_selected_params = {}
      params_list.each do |p|
        only_selected_params[p] = params[p] if params.has_key?(p.to_s)
      end
      return only_selected_params
    end
    
    # Authentication
    
    before do
      required_params(params, :access_key, :signature, :timestamp)
      
      # Ignore file uplaods and params from SWFUpload (Filename and Upload)
      params_to_hash = params.dup
      ['file', 'signature', 'Filename', 'Upload'].each {|v| params_to_hash.delete(v) }
      params_to_hash['access_key'] = Panda::Config[:access_key]
      
      signature = ApiAuthentication.authenticate(request.env['REQUEST_METHOD'], request.env['PATH_INFO'], request.env['SERVER_NAME'], Panda::Config[:secret_key], params_to_hash)
      raise(NotAuthorized, "Signatures do not match") unless signature == params['signature']
    end
    
    # Videos
    
    get '/videos.*' do
      display_response Video.find(:all), params[:splat].first
    end
  
    get '/videos/:id.*' do
      display_response(Video.find(params[:id]), params[:splat].first)
    end
    
    get '/videos/:id/encodings.*' do
      display_response(Video.find(params[:id]).encodings, params[:splat].first)
    end

    # HTML uplaod method where video data is uploaded directly
    # TODO: allow url param with location of external video
    # Allows both /videos.json and /videos.html
    post '/videos.*' do
      # puts params.inspect
      # puts request.env.inspect
      request.env['panda.iframe'] = params[:iframe].to_bool
      
      required_params(params, :upload_key, :upload_redirect_url, :state_update_url)
      
      video = Video.create_from_upload(params[:file], params[:state_update_url],  params[:upload_redirect_url])
      
      # if PANDA_ENV == :test
      #   video.upload_to_store
      #   video.queue_encodings
      # else
        # run_later do # TODO: ensure run_later timeout is long enough
          video.upload_to_store
          video.queue_encodings
        # end
      # end
      
      display_response(video, params[:splat].first)
    end
    
    put '/videos/:id.*' do
      video = Video.find(params[:id])
      video.update_attributes(select_params(params, :upload_redirect_url, :state_update_url, :thumbnail_position))
      display_response(video, params[:splat].first)
    end
    
    delete '/videos/:id.*' do 
      video = Video.find(params[:id])
      video.obliterate!
      status 200
    end
    
    # Encodings

    get '/encodings.*' do
      if Encoding.aasm_states.map {|s| s.name.to_s }.include?(params[:status])
        encodings = Encoding.find(:all, :conditions => ["status=?",params[:status]])
      else
        encodings = Encoding.find(:all)
      end
      
      display_response(encodings, params[:splat].first)
    end

    get '/encodings/:id.*' do
      display_response(Encoding.find(params[:idorstatus]), params[:splat].first)
    end

    post '/encodings.*' do
      required_params(params, :video_id, :profile_id)
      video = Video.find(params[:video_id])
      profile = Profile.find(params[:profile_id])
      encoding = Encoding.create_for_video_and_profile(video, profile)
      display_response(encoding, params[:splat].first)
    end

    delete '/encodings/:id.*' do 
      encoding = Encoding.find(params[:id])
      encoding.obliterate!
      status 200
    end
    
    # Profiles
    
    get '/profiles.*' do
      display_response(Profile.find(:all), params[:splat].first)
    end
    
    get '/profiles/:id.*' do
      display_response(Profile.find(params[:id]), params[:splat].first)
    end
    
    get '/profiles/:id/encodings.*' do
      display_response(Profile.find(params[:id]).encodings, params[:splat].first)
    end
    
    post '/profiles.*' do
      required_params(params, :width, :height, :category, :title, :extname, :command)
      profile = Profile.create(select_params(params, :width, :height, :category, :title, :extname, :command, :status))
      display_response(profile, params[:splat].first)
    end
    
    put '/profiles/:id.*' do
      profile = Profile.find(params[:id])
      profile.update_attributes(select_params(params, :width, :height, :category, :title, :extname, :command, :status))
      display_response(profile, params[:splat].first)
    end
    
    delete '/profiles/:id.*' do 
      profile = Profile.find(params[:id])
      raise(CannotDelete, "Couldn't delete Profile with ID=#{params[:id]} as it has associated encodings which must be deleted first. Maybe you want to disable the Profile instead by updating its status attribute to 'disabled'?") unless profile.encodings.empty?
      profile.destroy
      status 200
    end
  end
  
  class Root < Sinatra::Base
    get '/crossdomain.xml' do
      content_type :xml
      %(<?xml version="1.0"?>
      <!DOCTYPE cross-domain-policy SYSTEM "http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd">
      <cross-domain-policy>
         <allow-access-from domain="*" />
      </cross-domain-policy>)
    end
  end
end

# run Panda::Core