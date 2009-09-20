class FileStore < AbstractStore
  include FileUtils
  
  def initialize
    raise Panda::ConfigError, "You must specify public_videos_dir and videos_domain to use filesystem storage" unless Panda::Config[:public_videos_dir] && Panda::Config[:videos_domain]
    
    @dir = Panda::Config[:public_videos_dir]
    mkdir_p(@dir)
  end
  
  # Set file. Returns true if success.
  def set(key, tmp_file)
    cp(tmp_file, @dir / key)
    true
  end
  
  # Get file.
  def get(key, tmp_file)
    cp(@dir / key, tmp_file)
  rescue
    raise_file_error(key)
  end
  
  # Delete file. Returns true if success.
  def delete(key)
    rm(@dir / key)
  rescue
    raise_file_error(key)
  end
  
  # Return the publically accessible URL for the given key
  def url(key)
    %(http://#{Panda::Config[:videos_domain]}/#{key})
  end
end
