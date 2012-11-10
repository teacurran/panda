class ApplicationController < ActionController::Base


  def index
    redirect_to "/dashboard"
  end


  private

  def require_login
    case (params[:format] || "html")
      when "html"
        begin
          @user = User.find(session[:user_key]) if session[:user_key]
        rescue Amazon::SDB::RecordNotFoundError
          session[:user_key] = nil
          @user = nil
        end

        flash[:error] = "You must be logged in to access this section"
        redirect_to "/login"

      when "xml", "yaml"
        throw :halt, render('<error>Invalid account_key</error>', :status => 401) unless params[:account_key] == config.api_key
      else
        throw :halt, render('', :status => 401)
    end

  end


  def swfobject2_link
    "<script type=\"text/javascript\" charset=\"utf-8\" src= \"#{request.protocol}://#{request.host}/javascripts/swfobject2.js\"><\/script>"
  end

end