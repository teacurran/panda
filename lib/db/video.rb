require File.dirname(__FILE__)+'/video_base/store'

case Panda::Config[:database]
when :simpledb
  class Video < SimpleRecord::Base
    has_ints :duration, :width, :height, :fps
    has_attributes :extname, :original_filename, :container, :video_codec, :audio_codec, :thumbnail_position, :upload_redirect_url, :state_update_url
  end
when :mysql
  class Video < ActiveRecord::Base
  end
when :sqlite
  class Video < ActiveRecord::Base
  end
end

class Video
  include VideoBase::StoreMethods
  
  def self.all_with_status(status)
    self.find(:all, :conditions => ["status=?",status], :order => "created_at desc")
  end

  # TODO: enable notifications in a nicer way
  # def self.outstanding_notifications
  #   # TODO: Do this in one query
  #   self.all(:notification.not => "success", :notification.not => "error", :status => "success") +
  #   self.all(:notification.not => "success", :notification.not => "error", :status => "error") 
  # end

  def encodings
    Encoding.find(:all, :conditions => ["video_id=?",self.key])
  end

  # def successful_encodings
  #   self.class.find(:all)(:parent => self.key, :status => "success")
  # end

  def has_encoding_for_profile?(p)
    !Encoding.find(:all, :conditions => ["video_id=? and profile_id=?", self.key, p.key]).empty?
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
  
  # TODO: define these when the video is created via the API instead of in the config
  def get_upload_redirect_url
    self.upload_redirect_url.gsub(/\$id/, self.key)
  end
  
  def get_state_update_url
    self.state_update_url.gsub(/\$id/, self.key)
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
  
  
  def self.create_from_upload(file, state_update_url = nil, upload_redirect_url = nil)
    raise NoFileSubmitted if !file || file.blank?
    
    video = self.create
    video.extname = File.extname(file[:filename])
    raise FormatNotRecognised if video.extname.blank?
    # Split out any directory path Windows adds in
    video.original_filename = file[:filename].split("\\").last
    video.state_update_url = state_update_url
    video.upload_redirect_url = upload_redirect_url
    
    # Move file into tmp location
    FileUtils.mv file[:tempfile].path, video.tmp_filepath
    
    video.read_metadata
    video.save
    Log.info video.inspect
    return video
  end
  
  # Reads information about the video into attributes.
  # 
  # Raises FormatNotRecognised if the video is not valid
  # 
  def read_metadata
    Log.info "#{self.key}: Reading metadata of video file"
    
    inspector = RVideo::Inspector.new(:file => self.tmp_filepath)
    raise FormatNotRecognised unless inspector.valid? and inspector.video?
    
    [:duration, :fps, :width, :height, :video_codec, :audio_codec].each do |k|
      self.send("#{k}=", (inspector.send(k) rescue nil))
    end
    
    # Don't allow videos with a duration of 0
    raise FormatNotRecognised if self.duration == 0
  end
  
  # TODO: Breakout Profile adding into a different method
  def queue_encodings
    # Die if there aren't any profiles
    if Profile.find(:all).empty?
      Log.error "There are no encoding profiles!"
      return nil
    end
    
    # TODO: Allow manual selection of encoding profiles used in both form and api
    # For now we will just encode to all available profiles
    Profile.find(:all).each do |p|
      Log.info p.inspect
      self.create_encoding_for_profile(p) unless self.has_encoding_for_profile?(p)
    end
    
    return true
  end
  
  def create_encoding_for_profile(p)
    encoding = Encoding.new
    encoding.video_id = self.key
    encoding.profile_id = p.key
    [:extname, :width, :height].each do |k|
      encoding.send("#{k}=", p.send(k))
    end
    encoding.save
    Log.info encoding.inspect
    return encoding
  end

  # API
  # ===

  # Hash of paramenters for video and encodings when video.xml/yaml requested.
  # 
  # See the specs for an example of what this returns
  # 
  def to_hash
    h = self.attributes
    h[:encodings] = self.encodings.map {|e| e.to_hash }
    return h
  end
  
  # Exceptions
  
  class VideoError < StandardError; end
  class NotificationError < StandardError; end
  
  # 422
  class NotValid < VideoError; end
  class NoFileSubmitted < VideoError; end
  class FormatNotRecognised < VideoError; end
end
