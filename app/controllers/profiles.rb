class Profiles < Application
  before :require_login
  
  # GET /profiles
  def index
    provides :html, :xml, :yaml
    @profiles = Profile.all
    display @profiles
  end

  # GET /profiles/:id
  def show
    provides :html, :xml, :yaml
    @profile = Profile.find(params[:id])
    display @profile
  end

  # GET /profiles/new
  def new
    @profile = Profile.new
    render
  end

  # GET /profiles/:id/edit
  def edit
    @profile = Profile.find(params[:id])
    render
  end

  # GET /profiles/:id/delete
  def delete
    @profile = Profile.find(params[:id])
    render
  end

  # POST /profiles
  def create
    @profile = Profile.new(nil,params[:profile])
    @profile.save
    
    if content_type == :html
      redirect '/profiles'
    else
      display @profile
    end
  end

  # PUT /profiles/:id
  def update
    @profile = Profile.find(params[:id])
    @profile.set_attributes(params[:profile])
    @profile.save
    if content_type == :html
      redirect '/profiles'
    else
      display @profile
    end
  end

  # DELETE /profiles/:id
  def destroy
    @profile = Profile.find(params[:id])
    @profile.destroy!
    if content_type == :html
      redirect '/profiles'
    else
      display true
    end
  end
end
