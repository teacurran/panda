require 'rubygems'
require 'sinatra'
require 'json'

require 'rest_client'
panda = RestClient::Resource.new 'http://localhost:5678'

set :public, "."

get '/' do
  erb :index
end

post '/done' do
  @video = JSON.parse(params[:video])
  erb :done
end

get '/status/:key.json' do
  content_type :json
  '('+panda["/videos/#{params[:key]}/encodings.json"].get+')'
end