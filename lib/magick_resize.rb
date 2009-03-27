class MagickResize
  def self.resample(filename_in, filename_out, size)
    `convert -sample #{size[0]}x#{size[1]} #{filename_in} #{filename_out}`
  end
end
