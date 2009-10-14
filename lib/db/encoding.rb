require File.dirname(__FILE__)+'/video_base/store'

case Panda::Config[:database]
when :simpledb
  class Encoding < SimpleRecord::Base
    has_ints :width, :height, :encoding_time, :encoding_progress
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
  
  def self.writeable_attributes
    []
  end
  
  belongs_to :video
  belongs_to :profile
  
  aasm_column :status
  
  aasm_state :queued
  aasm_state :assigned, :exit => :download_video
  aasm_state :encoding, :after_enter => :encode_video
  aasm_state :success, :enter => :upload_encoding, :after_enter  => :cleanup
  aasm_state :error, :enter => :save_error_logs, :after_enter  => :cleanup
  
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
    self.find(:first, :conditions => ["status='queued'"], :order => "created_at asc")
  end
  
  def self.create_for_video_and_profile(video, profile)
    encoding = Encoding.new
    encoding.video_id = video.id
    encoding.profile_id = profile.id
    [:extname, :width, :height].each do |k|
      encoding.send("#{k}=", profile.send(k))
    end
    encoding.save
    Log.info encoding.inspect
    return encoding
  end
  
  def log_filename
    self.id + '.log'
  end
  
  def tmp_log_filepath
    File.join(Panda::Config[:encoding_log_dir],self.log_filename)
  end
  
  # API
  # ===
  
  def obliterate!
    self.delete_from_store
    self.destroy
  end
  
  # Encoding
  # ========
  
  # If a custom log is defined use that otherwise use the global log.
  attr_writer :log
  def log
    @log || Log
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
      self.log.info "Couldn't do w/h to caculate aspect. Just using the output resolution now."
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
      :resolution_and_padding => self.ffmpeg_resolution_and_padding_no_cropping,
      
      :width => self.width,
      :height => self.height,
      
      :id => self.id,
      :videos_domain => Panda::Config[:videos_domain],
      
      :progress_sample_rate => 1,
      :progress_timeout => 60
    }
  end
  
  def download_video
    self.video.fetch_from_store
  end
  
  def encode_video
    self.started_encoding_at = Time.now
    self.save
    
    self.log.info "BEGIN"
    self.log.info self.inspect
    
    begin
      RVideo.logger = self.log
      transcoder = RVideo::Transcoder.new
      transcoder.execute(self.profile.command, recipe_options(self.video.tmp_filepath, self.tmp_filepath)) do |tool, progress|
        puts "PROGRESS: #{progress.inspect}"
        self.encoding_progress = progress
        self.save
      end
      
      self.encoding_time = (Time.now - self.started_encoding_at).to_i
      self.save
      Log.debug "SUCCESS #{self.id}"
      
      self.win!
    rescue => e # TODO: Specify some error type
      Log.debug "FAIL #{self.id}"
      self.log.error "FAIL"
      self.log.error "#{e.class} - #{e.message}"
      self.log.error self.inspect
      
      self.fail!
    end
  end
  
  def upload_encoding
    self.upload_to_store
  end
  
  def save_error_logs
    Store.set(self.log_filename, self.tmp_log_filepath)
  end
  
  def cleanup
    self.all_files_matching_id.each {|fn| FileUtils.rm fn, :force => true }
    FileUtils.rm self.video.tmp_filepath, :force => true
  end
end