class Profiles < Application
  before :require_login
  before :set_profile, :only => [:show, :edit, :update, :destroy]
  
  # GET /profiles
  def index
    provides :html, :xml, :yaml
    @profiles = Profile.all
    display @profiles
  end

  # GET /profiles/:id
  def show
    provides :html, :xml, :yaml
    @profile = Profile[params[:id]]
    display @profile
  end

  # GET /profiles/new
  def new
    @profile = Profile.new
    render
  end

  # GET /profiles/:id/edit
  def edit
    @profile = Profile[params[:id]]
    render
  end

  # POST /profiles
  def create
    @profile = Profile.new(params[:profile])
    @profile.save
    
    if content_type == :html
      redirect '/profiles'
    else
      display @profile
    end
  end

  # PUT /profiles/:id
  def update
    @profile = Profile[params[:id]]
    @profile.update_attributes(params[:profile])
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
  
private

  def set_profile
    @profile = Profile.get!(params[:id])
    rescue DataMapper::ObjectNotFoundError
      raise NotFound
  end
end
