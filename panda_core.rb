require 'rubygems'
require 'sinatra/base'
require 'simple_record'

require 'lib/panda'

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