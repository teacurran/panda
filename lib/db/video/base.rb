module VideoBase
  class Base
  
    # Classification
    # ==============
  
    def encoding?
      ['queued', 'processing', 'success', 'error'].include?(self.status)
    end
  
    def parent?
      ['original', 'empty'].include?(self.status)
    end
  
    # Attr helpers
    # ============
  
    # Location to store video file fetched from S3 for encoding
    def tmp_filepath
      private_filepath(self.filename)
    end
    def duration_str
      s = (self.duration.to_i || 0) / 1000
      "#{sprintf("%02d", s/60)}:#{sprintf("%02d", s%60)}"
    end
  
    def resolution
      self.width ? "#{self.width}x#{self.height}" : nil
    end
  
    def video_bitrate_in_bits
      self.video_bitrate.to_i * 1024
    end
  
    def audio_bitrate_in_bits
      self.audio_bitrate.to_i * 1024
    end
  
    # Encding attr helpers
    # ====================
  
    def url
      Store.url(self.filename)
    end
  
    # Interaction with store
    # ======================
  
    def upload_to_store
      Store.set(self.filename, self.tmp_filepath)
    end
  
    def fetch_from_store
      Store.get(self.filename, self.tmp_filepath)
    end
  
    # Deletes the video file without raising an exception if the file does not exist.
    def delete_from_store
      Store.delete(self.filename)
      self.clippings.each { |c| c.delete_from_store }
      Store.delete(self.clipping.filename(:screenshot, :default => true))
      Store.delete(self.clipping.filename(:thumbnail, :default => true))
    rescue AbstractStore::FileDoesNotExistError
      false
    end
  
    # API
    # ===
  
    # Hash of paramenters for video and encodings when video.xml/yaml requested.
    # 
    # See the specs for an example of what this returns
    # 
    def show_response
      r = {
        :video => {
          :id => self.id,
          :status => self.status
        }
      }
    
      # Common attributes for originals and encodings
      if self.status == 'original' or self.encoding?
        [:filename, :original_filename, :width, :height, :duration].each do |k|
          r[:video][k] = self.send(k)
        end
        r[:video][:screenshot]  = self.clipping.filename(:screenshot)
        r[:video][:thumbnail]   = self.clipping.filename(:thumbnail)
      end
    
      # If the video is a parent, also return the data for all its encodings
      if self.status == 'original'
        r[:video][:encodings] = self.encodings.map {|e| e.show_response}
      end
    
      # Reutrn extra attributes if the video is an encoding
      if self.encoding?
        r[:video].merge! \
          [:parent, :profile, :profile_title, :encoded_at, :encoding_time].
            map_to_hash { |k| {k => self.send(k)} }
      end
    
      return r
    end
  
  end
end