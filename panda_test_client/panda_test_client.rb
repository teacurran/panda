require 'rubygems'
require 'sinatra'

set :public, "."

get '/' do
  erb :index
end