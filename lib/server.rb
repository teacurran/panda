$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'..'))
require 'sinatra/base'
require 'json'
require 'lib/run_later'
require 'lib/panda'

# Logger
# ======
 
Log = Logger.new("sinatra.log") # or log/development.log, whichever you prefer
Log.level  = Logger::INFO
# I'm assuming the other logging levels are debug &amp; error, couldn't find documentation on the different levels though
Log.info "Why isn't this working #{@users.inspect}"

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
      params_list.each {|p| raise InvalidRequest unless params.has_key?(p.to_s) }
    end
    
    get '/videos.*' do
      # Allow scope by status
      # Store a model object to SimpleDB
      mm = MyModel.new
      mm.name = "Travis"
      mm.age = 32
      mm.save
      id = mm.id

      # Get an object from SimpleDB
      mm2 = MyModel.find(id)
      'got=' + mm2.name + ' and he/she is ' + mm.age.to_s + ' years old'
    end
    
    
    # error InvalidRequest do
    #   'You got it wrong'
    # end
    
    # HTML uplaod method where video data is uploaded directly
    post '/videos' do
      begin
        required_params(params, :upload_redirect_url, :state_update_url)
        
        video = Video.create_from_upload(params[:file])
        video.upload_redirect_url = params[:upload_redirect_url] 
        video.state_update_url = params[:state_update_url]
        
        run_later do # TODO: ensure run_later timeout is long enough
          video.upload_to_store
          video.queue_encodings
        end
        
        # TODO instead of one custom_params param maybe passthorugh everything starting with custom_ ?
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
    
    post '/videos.*' do
      # begin
        required_params(params, :state_update_url)
        video = Video.create_from_upload(params[:file])
        video.state_update_url = params[:state_update_url]
        video.upload_to_store
        video.queue_encodings
        
        status 200
        response video, params[:splat].first
        # TODO: handle errors with Sinatra's error blocks
        
      # rescue Video::NotValid
      #   status 422
      # rescue Video::VideoError
      #   status 500
      # end
    end
  end
end

# run Panda::Core