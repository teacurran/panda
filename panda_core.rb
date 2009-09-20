require 'lib/panda'
require 'sinatra/base'

# Logger
# ======
 
configure do
  Log = Logger.new("sinatra.log") # or log/development.log, whichever you prefer
  Log.level  = Logger::INFO
  # I'm assuming the other logging levels are debug &amp; error, couldn't find documentation on the different levels though
  Log.info "Why isn't this working #{@users.inspect}"
end

module Panda
  class Core < Sinatra::Base
    get '/videos' do
      # Allow scope by status
      # Store a model object to SimpleDB
      mm = MyModel.new
      mm.name = "Travis"
      mm.age = 32
      mm.save
      id = mm.id

      # Get an object from SimpleDB
      mm2 = MyModel.find(id)
      'got=' + mm2.name + ' and he/she is ' + mm.age.to_s + ' years old'
    end
  end
end

# run Panda::Core