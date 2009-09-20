require 'video_base/store'

case Panda::Config[:database]
when :simpledb
  class Encoding < SimpleRecord::Base
    has_ints :duration, :width, :height, :encoding_time
    has_attributes :filename, :status, :video_id, :profile_id, :command
    has_dates :queued_at, :started_encoding_at
  end
when :mysql
  class Encoding < ActiveRecord::Base
  end
end

class Encoding
  include VideoBase::Store
  
  belongs_to :video
  belongs_to :profile
  
  # API
  # ===

  # Hash of paramenters for video and encodings when video.xml/yaml requested.
  # 
  # See the specs for an example of what this returns
  # 
  def show_response
    r = {:video => {}}
  
    [:id, :filename, :video_id, :status, :profile_id, :command, :duration, :width, :height, :encoding_time, :queued_at, :started_encoding_at, :updated, :created].each do |k|
      r[:video][k] = self.send(k)
    end
    # r[:video][:screenshot]  = self.clipping.filename(:screenshot)
    # r[:video][:thumbnail]   = self.clipping.filename(:thumbnail)
    return r
  end
  
  # Encoding
  # ========

  def ffmpeg_resolution_and_padding
    # Calculate resolution and any padding
    in_w = self.video.width.to_f
    in_h = self.video.height.to_f
    out_w = self.width.to_f
    out_h = self.height.to_f

    begin
      aspect = in_w / in_h
    rescue
      Merb.logger.error "Couldn't do w/h to caculate aspect. Just using the output resolution now."
      return %(-s #{self.width}x#{self.height})
    end

    height = (out_w / aspect.to_f).to_i
    height -= 1 if height % 2 == 1

    opts_string = %(-s #{self.width}x#{height} )

    # Crop top and bottom is the video is too tall, but add top and bottom bars if it's too wide (aspect wise)
    if height > out_h
      crop = ((height.to_f - out_h) / 2.0).to_i
      crop -= 1 if crop % 2 == 1
      opts_string += %(-croptop #{crop} -cropbottom #{crop})
    elsif height < out_h
      pad = ((out_h - height.to_f) / 2.0).to_i
      pad -= 1 if pad % 2 == 1
      opts_string += %(-padtop #{pad} -padbottom #{pad})
    end

    return opts_string
  end

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
      Merb.logger.error "Couldn't do w/h to caculate aspect. Just using the output resolution now."
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

  def execute_encode
    transcoder = RVideo::Transcoder.new
    transcoder.execute(self.command, recipe_options(self.video.tmp_filepath, self.tmp_filepath))
  end

  def encode
    raise "You can only encode encodings" unless self.encoding?
    self.status = "processing"
    self.save

    begun_encoding = Time.now

    begin
      Log.info "(#{Time.now.to_s}) Encoding #{self.id}"

      self.video.fetch_from_store

      self.execute_encode
      self.upload_to_store
      
      # self.generate_thumbnail_selection
      # self.clipping.set_as_default
      # self.upload_thumbnail_selection
  
      self.notification = 0
      self.status = "success"
      self.encoded_at = Time.now
      self.encoding_time = (Time.now - begun_encoding).to_i
      self.save

      Log.info "Removing tmp video files"
      FileUtils.rm self.tmp_filepath
      FileUtils.rm self.video.tmp_filepath
  
      Log.info "Encoding successful"
    rescue
      self.notification = 0
      self.status = "error"
      self.save
      FileUtils.rm self.video.tmp_filepath
  
      Merb.logger.error "Unable to transcode file #{self.id}: #{$!.class} - #{$!.message}"
    
      raise
    end
  end
end