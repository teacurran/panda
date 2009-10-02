$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'..'))
require 'lib/panda'

Log.info 'Encoder awake!'

loop do
  sleep rand(8) # Randomize the sleep so that the servers don't all wake up at the same time
  Log.debug "Checking for messages... #{Time.now}"
  
  if encoding = Encoding.get_job
    begin
      video.encode
    rescue  
      Log.error("Error encoding #{encoding.key}\n#{$!}\n\n#{encoding.inspect}\n#{encoding.video.inspect}" rescue "Error logging encoding error!")
    end
  end
end