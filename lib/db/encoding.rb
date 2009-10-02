require File.dirname(__FILE__)+'/video_base/store'

case Panda::Config[:database]
when :simpledb
  class Encoding < SimpleRecord::Base
    has_ints :width, :height, :encoding_time
    has_attributes :extname, :status, :video_id, :profile_id
    has_dates :started_encoding_at
  end
when :mysql
  class Encoding < ActiveRecord::Base
  end
when :sqlite
  class Encoding < ActiveRecord::Base
  end
end

class Encoding
  include AASM
  include VideoBase::StoreMethods
  
  belongs_to :video
  belongs_to :profile
  
  aasm_column :status
  
  aasm_state :queued
  aasm_state :assigned, :exit => :download_video
  aasm_state :encoding, :enter => :encode_video
  aasm_state :success, :enter => :upload_encoding, :after_enter  => :cleanup
  aasm_state :error, :enter => :save_logs, :after_enter  => :cleanup
  
  aasm_initial_state :queued
  
  aasm_event :claim do
    transitions :from => :queued, :to => :assigned
  end
  
  aasm_event :encode do
    transitions :from  => :assigned, :to => :encoding
  end
  
  aasm_event :win do
    transitions :from => :encoding, :to => :success
  end
  
  aasm_event :fail do
    transitions :from => :encoding, :to => :error
  end
  

  def self.get_job
    self.find(:first, :conditions => "status='queued'", :order => "created_at asc")
  end
  
  # API
  # ===

  # Hash of paramenters for video and encodings when video.xml/yaml requested.
  # 
  # See the specs for an example of what this returns
  # 
  def to_hash
    self.attributes
  end
  
  # Encoding
  # ========

  def ffmpeg_resolution_and_padding_no_cropping
    # Calculate resolution and any padding
    in_w = self.video.width.to_f
    in_h = self.video.height.to_f
    out_w = self.width.to_f
    out_h = self.height.to_f

    begin
      aspect = in_w / in_h
      aspect_inv = in_h / in_w
    rescue
      Log.info "Couldn't do w/h to caculate aspect. Just using the output resolution now."
      return %(-s #{self.width}x#{self.height} )
    end

    height = (out_w / aspect.to_f).to_i
    height -= 1 if height % 2 == 1

    opts_string = %(-s #{self.width}x#{height} )

    # Keep the video's original width if the height
    if height > out_h
      width = (out_h / aspect_inv.to_f).to_i
      width -= 1 if width % 2 == 1

      opts_string = %(-s #{width}x#{self.height} )
      self.width = width
      self.save
    # Otherwise letterbox it
    elsif height < out_h
      pad = ((out_h - height.to_f) / 2.0).to_i
      pad -= 1 if pad % 2 == 1
      opts_string += %(-padtop #{pad} -padbottom #{pad})
    end

    return opts_string
  end

  def recipe_options(input_file, output_file)
    {
      :input_file => input_file,
      :output_file => output_file,
      :resolution_and_padding => self.ffmpeg_resolution_and_padding_no_cropping
    }
  end
  
  def download_video
    self.video.fetch_from_store
  end
  
  def encode_video
    begun_encoding = Time.now

    begin
      transcoder = RVideo::Transcoder.new
      transcoder.execute(self.command, recipe_options(self.video.tmp_filepath, self.tmp_filepath))
      
      self.encoded_at = Time.now
      self.encoding_time = (Time.now - begun_encoding).to_i
      self.save
      
      self.success!
    rescue # TODO: Specify some error type
      
      self.fail!
    end
  end
  
  def upload_encoding
    self.upload_to_store
  end
  
  def save_logs
    Log.info "TODO: Save logs for video file to store so it can be debugged at a later date."
  end
  
  def cleanup
    FileUtils.rm self.tmp_filepath
    FileUtils.rm self.video.tmp_filepath
  end
end