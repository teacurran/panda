raise "config.FFMPEG not set or not executable" unless File.exists?(Panda::Application.config.FFMPEG.to_s) && File.executable?(Panda::Application.config.FFMPEG.to_s)
