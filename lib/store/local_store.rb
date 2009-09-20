module LocalStore
  
  def self.ensure_directories_exist
    private_dir = Panda::Config[:private_tmp_path]
    public_dir  = Panda::Config[:public_tmp_path]
    
    FileUtils.mkdir_p(private_dir)
    FileUtils.mkdir_p(public_dir)
  end
  
  private
  
  # This path can be accessible from the web
  def public_filepath(*args)
    add_filename_to(:public_tmp_path, *args)
  end
  
  # URL on the panda instance (before it has been uploaded)
  def public_url(*args)
    add_filename_to(:public_tmp_url, *args)
  end
  
  def private_filepath(*args)
    add_filename_to(:private_tmp_path, *args)
  end
  
  def add_filename_to(option, *args)
    Panda::Config[option] / args.map { |e| e.to_s }.join('_')
  end
  
end
