class FileStore < AbstractStore
  def initialize
    raise RuntimeError, "You must specify public_videos_dir and videos_domain to use filesystem storage" unless Panda::Config[:public_videos_dir] && Panda::Config[:videos_domain]
    
    @dir = Panda::Config[:public_videos_dir]
    FileUtils.mkdir_p(@dir)
  end
  
  # Set file. Returns true if success.
  def set(key, tmp_file)
    FileUtils.mv(tmp_file, File.join(@dir, key))
    true
  end
  
  # Get file.
  def get(key, tmp_file)
    FileUtils.mv(File.join(@dir / key), tmp_file)
  rescue
    raise_file_error(key)
  end
  
  # Delete file. Returns true if success.
  def delete(key)
    FileUtils.rm(@dir / key)
  rescue
    raise_file_error(key)
  end
  
  # Return the publically accessible URL for the given key
  def url(key)
    %(http://#{Panda::Config[:videos_domain]}/#{key})
  end
end
