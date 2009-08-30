class Profiles < Application
  before :require_login
  before :set_profile, :only => [:show, :edit, :update, :destroy]
  
  # GET /profiles
  def index
    provides :json
    @profiles = Profile.all
    display @profiles
  end

  # GET /profiles/:id
  def show
    provides :json
    display @profile
  end

  # GET /profiles/new
  def new
    @profile = Profile.new
    render
  end

  # GET /profiles/:id/edit
  def edit
    render
  end

  # POST /profiles
  def create
    @profile = Profile.new(params[:profile])
    @profile.save
    display @profile
  end

  # PUT /profiles/:id
  def update
    @profile.update_attributes(params[:profile])
    @profile.save
    display @profile
  end

  # DELETE /profiles/:id
  def destroy
    @profile.destroy
    display true
  end
  
private

  def set_profile
    @profile = Profile.get!(params[:id])
    rescue DataMapper::ObjectNotFoundError
      raise NotFound
  end
end
