class Videos < Application
  before :require_login, :only => [:index, :show, :destroy, :new, :create, :add_to_queue]
  before :set_video, :only => [:show, :destroy, :add_to_queue]
  before :set_video_with_nice_errors, :only => [:done, :state]

  ERROR_MESSAGES = YAML.load_file(Merb.root / 'config' / 'error_messages.yml')

  def index
    provides :html, :xml, :yaml
    
    @videos = Video.all
    
    display @videos
  end

  def show
    provides :html, :xml, :yaml
    
    case content_type
    when :html
      # TODO: use proper auth method
      @user = User.find(session[:user_key]) if session[:user_key]
      if @user
        if @video.status == "original"
          render :show_parent
        else
          render :show_encoding
        end
      else
        redirect("/login")
      end
    when :xml
      @video.show_response.to_simple_xml
    when :yaml
      @video.show_response.to_yaml
    end
  end
  
  # Use: HQ
  # Only used in the admin side to post to create and then forward to the form 
  # where the video is uploaded
  def new
    render :layout => :simple
  end
  
  # Use: HQ
  def destroy
    @video.obliterate!
    redirect "/videos"
  end

  # Use: HQ, API
  def create
    provides :html, :xml, :yaml
    
    @video = Video.create_empty
    Merb.logger.info "#{@video.key}: Created video"
    
    case content_type
    when :html
      redirect "/videos/upload_form"
    when :xml
      headers.merge!({'Location'=> "/videos/#{@video.key}"})
      @video.create_response.to_simple_xml
    when :yaml
      headers.merge!({'Location'=> "/videos/#{@video.key}"})
      @video.create_response.to_yaml
    end
  end
  
  # Use: HQ, API, iframe upload
  def upload_form
    if params[:success_url] && params[:error_url]
      @progress_id = String.random(24)
      render :layout => :uploader
    else
      raise BadRequest, "You must include success_url and error_url in your query!"
    end
  end
  
  # POST /videos/:id/upload
  # Use: HQ, http/iframe upload
  # def upload
  #   @video = Video.find(params[:id])
  #   receive_upload_for(@video)
  # end

  # POST /videos/upload
  # This receives an upload of a new video before any associated record was received.
  def upload
    @video = Video.create_empty
    receive_upload_for(@video)
  end
  
  def upload_via_api
    begin
      @results = {}
      @state = "error"
      @video = Video.create_empty
      @video.initial_processing(params[:file])
      @video.finish_processing_and_queue_encodings
    rescue Amazon::SDB::RecordNotFoundError, Video::NotValid # No empty video object exists
      @results.merge! error_hash(404)
    rescue Video::FormatNotRecognised
      @results.merge! error_hash(415)
    rescue Video::ClippingError
      @results.merge! error_hash(422)
    rescue => e # Other error
      # TODO: Should log this error.
      @results.merge! error_hash(500)
    else
      @state = "success"
      @results.merge! :video_file_id => @video.key
    end
    render :action => "upload_via_api", :layout => false
  end
  
  # Default success_url (set in panda_init.rb) goes here.
  def done
    render :layout => :uploader
  end
  
  # TODO: Why do we need this method?
  def add_to_queue
    @video.add_to_queue
    redirect "/videos/#{@video.key}"
  end
  
private

  # TODO: figure how to #finish_processing_and_queue_encodings using #render_then_call while still capturing Video::ClippingErrors which occur during processing
  def receive_upload_for(video)
    begin
      video.initial_processing(params[:file])
      video.finish_processing_and_queue_encodings
      response_data = {:status => '200', :video_file_id => video.key, :video_filename => video.original_filename}
      if params[:return_to]
        redirect return_to_with_params(response_data)
      else
        render iframe_params(:location => url_with_params(params[:success_url], response_data))
      end
    rescue Amazon::SDB::RecordNotFoundError, Video::NotValid # No empty video object exists
      render_error(404)
    rescue Video::FormatNotRecognised
      render_error(415)
    rescue Video::ClippingError
      render_error(422)
    rescue => e # Other error
      # TODO: Should log this error.
      render_error(500)
    end
  end
  
  def set_video
    # Throws Amazon::SDB::RecordNotFoundError if video cannot be found
    @video = Video.find(params[:id])
  end
  
  def set_video_with_nice_errors
    begin
      @video = Video.find(params[:id])
    rescue Amazon::SDB::RecordNotFoundError
      throw :halt, render_iframe_error(404)
    end
  end

  def error_hash(code)
    {:status => code.to_s, :message => ERROR_MESSAGES[code]}
  end

  def render_error(code)
    if params[:return_to]
      redirect return_to_with_params(error_hash(code))
    else
      render_iframe_error(code)
    end
  end

  def render_iframe_error(code)
    self.status = code
    render iframe_params(:location => url_with_params(params[:error_url], error_hash(code))), :layout => false
  end
  
  def url_with_params(url, params)
    return if url.blank?
    params.each do |key,value|
      url << (url =~ /\?/ ? '&' : '?')
      url << CGI.escape(key.to_s) << '=' << CGI.escape(value)
    end
    url
  end
  
  # Textarea hack to get around the fact that the form is submitted with a 
  # hidden iframe and thus the response is rendered in the iframe.
  # This works with jquery.form.
  def iframe_params(options)
    "<textarea>" + options.to_json + "</textarea>"
  end

  def return_to_with_params(options)
    params[:return_to] + (params[:return_to] =~ /\?/ ? '&' : '?') + "json=" + CGI.escape(options.to_json)
  end
end
