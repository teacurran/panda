module VideoBase
  module StoreMethods
    def filename
      self.id + self.extname
    end
    
    def tmp_filepath
      File.join(Panda::Config[:private_tmp_path], self.filename)
    end
  
    def url
      Store.url(self.filename)
    end
    
    def all_files_matching_id
      Dir[File.join(Panda::Config[:private_tmp_path], self.id)+'*']
    end
  
    # Instead of just uploading the specific filename given by tmp_filepath (as fetch_from_store does), we upload all files which start with the id of this one. This is so that when we encode a video which spits out lots of videos like the iPhone stream segmenter does, they all get uploaded to the store.
    def upload_to_store
      all_files_matching_id.each do |fn|
        Store.set(File.basename(fn), fn) unless File.extname(fn) == '.log' # Except logs. TODO: nicer way to do this
      end
    end
  
    def fetch_from_store
      Store.get(self.filename, self.tmp_filepath)
    end
  
    # Deletes the video file without raising an exception if the file does not exist.
    def delete_from_store
      Store.delete(self.filename)
      # TODO: clippings
      # self.clippings.each { |c| c.delete_from_store }
      # Store.delete(self.clipping.filename(:screenshot, :default => true))
      # Store.delete(self.clipping.filename(:thumbnail, :default => true))
    rescue AbstractStore::FileDoesNotExistError
      false
    end
  end
end