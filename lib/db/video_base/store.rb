module VideoBase
  module Store
    # Location to store video file fetched from S3 for encoding
    def tmp_filepath
      private_filepath(self.filename)
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
      self.clippings.each { |c| c.delete_from_store }
      Store.delete(self.clipping.filename(:screenshot, :default => true))
      Store.delete(self.clipping.filename(:thumbnail, :default => true))
    rescue AbstractStore::FileDoesNotExistError
      false
    end
  end
end