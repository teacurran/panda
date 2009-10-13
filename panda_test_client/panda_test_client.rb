require 'rubygems'
require 'sinatra'
require 'json'

require 'panda'

Panda.connect!("e339e090-9a28-012c-bb3e-001ec2b5c0e1", "ed710840-9a28-012c-bb43-001ec2b5c0e1", 'localhost', 5678)

set :public, "."

get '/' do
  @params_to_post = {}
  @params_to_post['upload_key'] = UUID.new.generate
  @params_to_post['upload_redirect_url'] = "http://localhost:4567/videos/$id/done"
  @params_to_post['state_update_url'] = "http://localhost:4567/videos/$id/update"
  @params_to_post = Panda.authenticate("POST", "/videos.json", @params_to_post)
  
  erb :index
end

post '/done' do
  @video = JSON.parse(params[:video])
  erb :done
end

get '/status/:key.json' do
  content_type :json
  '('+Panda.get("/videos/#{params[:key]}/encodings.json")+')'
end