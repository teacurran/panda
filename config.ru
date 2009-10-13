require 'rubygems'
require 'bin/server'

map '/v2' do
  run Panda::Server
end

map '/' do
  run Panda::Root
end