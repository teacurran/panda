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
  
    def upload_to_store
      Store.set(self.filename, self.tmp_filepath)
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