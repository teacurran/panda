$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'..'))
require 'lib/panda'

Log.info "Encoder awake! #{Time.now}"

loop do
  sleep rand(8) # Randomize the sleep so that the servers don't all wake up at the same time
  Log.debug "Checking for messages... #{Time.now}"
  begin
    if encoding = Encoding.get_job
      Log.debug "PROCESSING #{encoding.key}"
      encoding.log = Logger.new(encoding.tmp_log_filepath)
      encoding.log.level = Logger::DEBUG

      encoding.claim!
      encoding.encode!
    end
  rescue => e
    Log.error "APP LEVEL ENCODING ERROR"
    Log.error "#{e.class} - #{e.message}"
  end
end