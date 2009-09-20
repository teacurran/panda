require 'video_base/store'

case Panda::Config[:database]
when :simpledb
  class Video < SimpleRecord::Base
    has_ints :duration, :width, :height, :fps
    has_attributes :filename, :original_filename, :container, :video_codec,  :audio_codec, :thumbnail_position, :upload_redirect_url, :state_update_url
    has_dates :uploaded_at # TODO implement uploaded_at
  end
when :mysql
  class Video < ActiveRecord::Base
  end
end

class Video
  include VideoBase::Store
  
  def self.all_with_status(status)
    self.find(:all, :conditions => ["status=?",status], :order => "created_at desc")
  end

  def self.next_job
    self.find(:first, :conditions => "status='queued'", :order => "created_at asc")
  end

  # TODO: enable notifications in a nicer way
  # def self.outstanding_notifications
  #   # TODO: Do this in one query
  #   self.all(:notification.not => "success", :notification.not => "error", :status => "success") +
  #   self.all(:notification.not => "success", :notification.not => "error", :status => "error") 
  # end

  def encodings
    Encoding.find(:all, :conditions => ["parent_id=?",self.id])
  end

  # def successful_encodings
  #   self.class.all(:parent => self.id, :status => "success")
  # end

  def find_encoding_for_profile(p)
    Encoding.find(:all, :conditions => ["parent_id=? and profile_id=?", self.id, p.id])
  end
  
  def self.create_empty
    video = self.class.new
    video.status = 'empty'
    video.save
    
    return video
  end
  
  # Attr helpers
  # ============
  
  # Delete an original video and all it's encodings.
  def obliterate!
    # TODO: should this raise an exception if the file does not exist?
    self.delete_from_store
    self.encodings.each do |e|
      e.delete_from_store
      e.destroy
    end
    self.destroy
  end
  
  # Has the actual video file been uploaded for encoding?
  def empty?
    self.original_filename == ""
  end
  
  # TODO: define these when the video is created via the API instead of in the config
  def get_upload_redirect_url
    self.upload_redirect_url.gsub(/\$id/, self.id)
  end
  
  def get_state_update_url
    self.state_update_url.gsub(/\$id/, self.id)
  end
  
  # Checks that video can accept new file, checks that the video is valid, 
  # reads some metadata from it, and moves video into a private tmp location.
  # 
  # File is the tempfile object supplied by merb. It looks like
  # {
  #   "content_type"=>"video/mp4", 
  #   "size"=>100, 
  #   "tempfile" => @tempfile, 
  #   "filename" => "file.mov"
  # }
  # 
  def initial_processing(file)
    raise NoFileSubmitted if !file || file.blank?
    raise NotValid unless self.empty?
    
    # Set filename and original filename
    self.filename = self.id + File.extname(file[:filename])
    # Split out any directory path Windows adds in
    self.original_filename = file[:filename].split("\\").last
    
    # Move file into tmp location
    FileUtils.mv file[:tempfile].path, self.tmp_filepath
    
    self.read_metadata
    self.status = "original"
    self.save
  end
  
  # Uploads video to store, generates thumbnails if required, cleans up 
  # temporary file, and adds encodings to the encoding queue.
  # 
  def finish_processing_and_queue_encodings
    self.upload_to_store
    
    # Generate thumbnails before we add to encoding queue
    self.generate_thumbnail_selection
    self.clipping(self.thumbnail_percentages.first).set_as_default
    self.upload_thumbnail_selection
    
    self.thumbnail_position = self.thumbnail_percentages.first
    self.save
    
    self.add_to_queue
    
    FileUtils.rm self.tmp_filepath
  end
  
  # Reads information about the video into attributes.
  # 
  # Raises FormatNotRecognised if the video is not valid
  # 
  def read_metadata
    Log.info "#{self.id}: Reading metadata of video file"
    
    inspector = RVideo::Inspector.new(:file => self.tmp_filepath)
    
    raise FormatNotRecognised unless inspector.valid? and inspector.video?
    
    self.duration = (inspector.duration rescue nil)
    self.container = (inspector.container rescue nil)
    self.width = (inspector.width rescue nil)
    self.height = (inspector.height rescue nil)
    
    self.video_codec = (inspector.video_codec rescue nil)
    self.video_bitrate = (inspector.bitrate rescue nil)
    self.fps = (inspector.fps rescue nil)
    
    self.audio_codec = (inspector.audio_codec rescue nil)
    self.audio_sample_rate = (inspector.audio_sample_rate rescue nil)
    
    # Don't allow videos with a duration of 0
    raise FormatNotRecognised if self.duration == 0
  end
  
  def create_encoding_for_profile(p)
    encoding = Video.new
    encoding.status = 'queued'
    encoding.filename = "#{encoding.id}.#{p.container}"
    
    # Attrs from the parent video
    encoding.parent = self.id
    [:original_filename, :duration].each do |k|
      encoding.send("#{k}=", self.attribute_get(k))
    end
    
    # Attrs from the profile
    encoding.profile = p.id
    [:width, :height, :command].each do |k|
      encoding.send("#{k}=", p.attribute_get(k))
    end
    
    encoding.save
    return encoding
  end
  
  # TODO: Breakout Profile adding into a different method
  def add_to_queue
    # Die if there aren't any profiles
    if Profile.all.empty?
      Merb.logger.error "There are no encoding profiles!"
      return nil
    end
    
    # TODO: Allow manual selection of encoding profiles used in both form and api
    # For now we will just encode to all available profiles
    Profile.all.each do |p|
      if self.find_encoding_for_profile(p).empty?
        self.create_encoding_for_profile(p)
      end
    end
    return true
  end
  
  # API
  # ===

  # Hash of paramenters for video and encodings when video.xml/yaml requested.
  # 
  # See the specs for an example of what this returns
  # 
  def show_response
    r = {:video => {}}
  
    [:id, :filename, :original_filename, :width, :height, :duration].each do |k|
      r[:video][k] = self.send(k)
    end
    # r[:video][:screenshot]  = self.clipping.filename(:screenshot)
    # r[:video][:thumbnail]   = self.clipping.filename(:thumbnail)
  
    # If the video is a parent, also return the data for all its encodings
    r[:video][:encodings] = self.encodings.map {|e| e.show_response}

    return r
  end
  
  # Exceptions
  
  class VideoError < StandardError; end
  class NotificationError < StandardError; end
  
  # 404
  class NotValid < VideoError; end
  
  # 500
  class NoFileSubmitted < VideoError; end
  class FormatNotRecognised < VideoError; end
end
