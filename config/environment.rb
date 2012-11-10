# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Panda::Application.initialize!

module Dates
  DATE_FORMAT = "%d% %b %Y"
  DATE_TIME_FORMAT = "#{DATE_FORMAT} %H:%M"
end

