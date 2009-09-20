module VideoBase
  class Encoding
    # Encoding
    # ========

    def ffmpeg_resolution_and_padding
      # Calculate resolution and any padding
      in_w = self.parent_video.width.to_f
      in_h = self.parent_video.height.to_f
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
      in_w = self.parent_video.width.to_f
      in_h = self.parent_video.height.to_f
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
        :container => self.container, 
        :video_codec => self.video_codec,
        :video_bitrate_in_bits => self.video_bitrate_in_bits.to_s, 
        :fps => self.fps,
        :audio_codec => self.audio_codec.to_s, 
        :audio_bitrate => self.audio_bitrate.to_s, 
        :audio_bitrate_in_bits => self.audio_bitrate_in_bits.to_s, 
        :audio_sample_rate => self.audio_sample_rate.to_s, 
        :resolution => self.resolution,
        :resolution_and_padding => self.ffmpeg_resolution_and_padding_no_cropping
      }
    end

    def encode_flv_flash
      Merb.logger.info "Encoding with encode_flv_flash"
      transcoder = RVideo::Transcoder.new
      recipe = "ffmpeg -i $input_file$ -ar 22050 -ab $audio_bitrate$k -f flv -b $video_bitrate_in_bits$ -r 24 $resolution_and_padding$ -y $output_file$"
      recipe += "\nflvtool2 -U $output_file$"
      transcoder.execute(recipe, self.recipe_options(self.parent_video.tmp_filepath, self.tmp_filepath))
    end

    def encode_mp4_aac_flash
      Merb.logger.info "Encoding with encode_mp4_aac_flash"
      transcoder = RVideo::Transcoder.new
      recipe = "ffmpeg -i $input_file$ -acodec libfaac -ar 48000 -ab $audio_bitrate$k -ac 2 -b $video_bitrate_in_bits$ -vcodec libx264 -rc_eq 'blurCplx^(1-qComp)' -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -coder 1 -flags +loop -cmp +chroma -partitions +parti4x4+partp8x8+partb8x8 -subq 5 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 $resolution_and_padding$ -r 24 -threads 4 -y $output_file$"
      transcoder.execute(recipe, self.recipe_options(self.parent_video.tmp_filepath, self.tmp_filepath))
    end

    def encode_unknown_format
      Merb.logger.info "Encoding with encode_unknown_format"
      transcoder = RVideo::Transcoder.new
      recipe = "ffmpeg -i $input_file$ -f $container$ -vcodec $video_codec$ -b $video_bitrate_in_bits$ -ar $audio_sample_rate$ -ab $audio_bitrate$k -acodec $audio_codec$ -r 24 $resolution_and_padding$ -y $output_file$"
      Merb.logger.info "Unknown encoding format given but trying to encode anyway."
      transcoder.execute(recipe, recipe_options(self.parent_video.tmp_filepath, self.tmp_filepath))
    end

    def encode
      raise "You can only encode encodings" unless self.encoding?
      self.status = "processing"
      self.save
  
      begun_encoding = Time.now
  
      begin
        encoding = self
        parent_obj = self.parent_video
        Merb.logger.info "(#{Time.now.to_s}) Encoding #{self.id}"
  
        parent_obj.fetch_from_store

        if self.container == "flv" and self.player == "flash"
          self.encode_flv_flash
        elsif self.container == "mp4" and self.audio_codec == "aac" and self.player == "flash"
          self.encode_mp4_aac_flash
        else # Try straight ffmpeg encode
          self.encode_unknown_format
        end
    
        self.upload_to_store
        self.generate_thumbnail_selection
        self.clipping.set_as_default
        self.upload_thumbnail_selection
    
        self.notification = 0
        self.status = "success"
        self.encoded_at = Time.now
        self.encoding_time = (Time.now - begun_encoding).to_i
        self.save

        Merb.logger.info "Removing tmp video files"
        FileUtils.rm self.tmp_filepath
        FileUtils.rm parent_obj.tmp_filepath
    
        Merb.logger.info "Encoding successful"
      rescue
        self.notification = 0
        self.status = "error"
        self.save
        FileUtils.rm parent_obj.tmp_filepath
    
        Merb.logger.error "Unable to transcode file #{self.id}: #{$!.class} - #{$!.message}"
      
        raise
      end
    end
  end
end