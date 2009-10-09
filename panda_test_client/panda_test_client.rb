require 'rubygems'
require 'sinatra'

set :public, "."

get '/' do
  erb :index
end

post '/upload' do
  params.inspect
end