# all your other controllers should inherit from this one to share code.
class Application < Merb::Controller
  # Auth plugin
  attr_accessor :user
  
  def index
    redirect "/dashboard"
  end

private

  def require_login
    provides :html, :xml, :yaml
    case (params[:format] || "html")
    when "html"
      begin
        @user = User.get!(session[:user_key]) if session[:user_key]
      rescue DataMapper::ObjectNotFoundError
        session[:user_key] = nil
        @user = nil
      end
      throw :halt, redirect("/login") unless @user
    when "xml", "yaml"
      response_hash = {:error => "InvalidAccountKey"}
      response_string = case params[:format]
                        when "xml"
                          response_hash.to_simple_xml
                        when "yaml"
                          response_hash.to_yaml
                        end
      throw :halt, render(response_string, :status => 401) unless params[:account_key] == Panda::Config[:api_key]
    else
      throw :halt, render('', :status => 401)
    end
  end
  
	
	def swfobject2_link
	 	"<script type=\"text/javascript\" charset=\"utf-8\" src= \"#{request.protocol}://#{request.host}/javascripts/swfobject2.js\"><\/script>"
	end
end  