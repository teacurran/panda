require 'rubygems'
require 'sinatra'
require 'json'
require 'uuidtools'

require 'panda'

Panda.connect!("e339e090-9a28-012c-bb3e-001ec2b5c0e1", "ed710840-9a28-012c-bb43-001ec2b5c0e1", 'ec2-72-44-37-190.compute-1.amazonaws.com', 80)

set :public, "."

get '/' do
  @params_to_post = {}
  @params_to_post['upload_key'] = UUID.timestamp_create().to_s
  @params_to_post['upload_redirect_url'] = "http://localhost:4567/videos/$id/done"
  @params_to_post['state_update_url'] = "http://localhost:4567/videos/$id/update"
  @params_to_post = Panda.authenticate("POST", "/videos.json", @params_to_post)
  
  erb :index
end

post '/done' do
  puts "DONE #{params.inspect}"
  @video = JSON.parse(params[:video])
  erb :done
end

get '/status/:id.json' do
  content_type :json
  '('+Panda.get("/videos/#{params[:id]}/encodings.json")+')'
end