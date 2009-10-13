$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),'..'))
require 'rubygems'
PANDA_ENV = :production
require 'lib/panda'

Log.info "Encoder awake! #{Time.now}"

loop do
  sleep rand(8) # Randomize the sleep so that the servers don't all wake up at the same time
  # Log.debug "Checking for messages... #{Time.now}"
  begin
    if encoding = Encoding.get_job
      Log.debug "PROCESSING #{encoding.id}"
      encoding.log = Logger.new(encoding.tmp_log_filepath)
      encoding.log.level = Logger::DEBUG

      encoding.claim!
      encoding.encode!
    end
  rescue => e
    # TODO: send these errors somewhere
    # TODO: sometimes we can get in an infinite loop on one video if there's a serious app error which means the encoding's status isn't set to error. Maybe we should in fact set the status to error here?
    Log.error "APP LEVEL ENCODING ERROR"
    Log.error "#{e.class} - #{e.message}"
  end
end