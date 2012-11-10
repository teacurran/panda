class AuthController < ActionController::Base
  respond_to :html
  # Auth plugin
  
  def login
    @user = User.new
    
    if request.post?
      if found_user = User.authenticate(params[:user][:login], params[:user][:password])
        session[:user_key] = found_user.login # AKA @user.key
        redirect_to "/"
      else
        @user.login = params[:user][:login] # The login is the key of our SDB record
        @notice = "Your username or password was incorrect."
      end
    end
    
    render
  end
  
  def logout
    session[:user_key] = nil
    redirect_to "/"
  end
end