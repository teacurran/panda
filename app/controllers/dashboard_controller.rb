class DashboardController < ApplicationController

  before_filter :require_login
  
  def index
    @queued_encodings = Video.queued_encodings
  end

end