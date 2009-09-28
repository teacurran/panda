require 'lib/panda'
require 'sinatra/base'
require 'json'
require 'lib/run_later'

# Logger
# ======
 
configure do
  Log = Logger.new("sinatra.log") # or log/development.log, whichever you prefer
  Log.level  = Logger::INFO
  # I'm assuming the other logging levels are debug &amp; error, couldn't find documentation on the different levels though
  Log.info "Why isn't this working #{@users.inspect}"
end

module Panda
  class Core < Sinatra::Base
    # TODO: Auth similar to Amazon where we hash all the form params plus the api key and send a signature
    
    # mime :json, "application/json"
    
    def response(object, ext)
      case ext.to_sym
      when :json
        content_type :json
        object.to_json
      when :xml
        content_type :xml
        object.to_xml
      end
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
    
    
    # HTML uplaod method where video data is uploaded directly
    post '/videos' do
      begin
        video = Video.new
        video.id = params[:id]
        video.initial_processing(params[:file])
        
        run_later do # TODO: ensure run_later timeout is long enough
          video.finish_processing_and_queue_encodings
        end
        
        # TODO return result in iframe textarea params
        redirect video.upload_redirect_url
      rescue Video::NotValid
        status 422
      rescue Video::VideoError
        status 500
      end
    end
    
    post '/videos.*' do
      begin
        video = Video.new
        video.id = params[:id]
        video.initial_processing(params[:file])
        video.finish_processing_and_queue_encodings
        status 200
        response video, params[:splat].first
      rescue Video::NotValid
        status 422
      rescue Video::VideoError
        status 500
      end
    end
  end
end

# run Panda::Core