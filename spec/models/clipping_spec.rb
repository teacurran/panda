require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Clipping do
  
  before :each do
    @parent_video = mock(Video)
    @video = mock(Video, :filename => "foo", :parent_video => @parent_video, :width => 10, :height => 20, :parent? => false)
    @clipping = Clipping.new(@video, 40)
  end
  
  describe "initialize" do
    it "should take video and store the reference" do
      clipping = Clipping.new(@video)
      clipping.instance_variable_get(:@video).should == @video
    end
  end
  
  describe "filename" do
    it "should be [video_filename]_[position]_thumb.jpg for :thumbnail" do
      @clipping.filename(:thumbnail).
        should == @video.filename + '_40_thumb.jpg'
    end
    
    it "should be [video_filename]_[position].jpg for :screenshot" do
      @clipping.filename(:screenshot).should == @video.filename + '_40.jpg'
    end
    
    it "should raise error for other sizes" do
      lambda {
        @clipping.filename(:something_else)
      }.should raise_error
    end
    
    it "should leave off the [position] component if sent default option" do
      @clipping.filename(:screenshot, :default => true).
        should == @video.filename + '.jpg'
    end
  end
  
  describe "url" do
    it "should fetch url info from store" do
      Store.should_receive(:url).with("#{@clipping.filename(:thumbnail)}").
        and_return('a')
      @clipping.url(:thumbnail).should == 'a'
    end
    
    it "should take a size option" do
      lambda {
        @clipping.url
      }.should raise_error
    end
    
    it "should raise error for invalid sizes" do
      lambda {
        @clipping.url(:something_else)
      }.should raise_error
    end
    
  end
  
  describe "tmp_url" do
    it "should use public_url to generate url" do
      @clipping.should_receive(:public_url).with(@video.filename, :thumbnail, 40, '.jpg')
      @clipping.tmp_url(:thumbnail)
    end
  end
  
  describe "position" do
    it "should read thumbnail_position from the parent video if not set when initialized" do
      @clipping2 = Clipping.new(@video)
      @parent_video.should_receive(:thumbnail_position).and_return(99)
      @clipping2.send(:position).should == 99
    end
    
    it "should be 50 if thumbnail_position not set" do
      @clipping2 = Clipping.new(@video)
      @parent_video.should_receive(:thumbnail_position).and_return(nil)
      @clipping2.send(:position).should == 50
    end
  end
  
  describe "upload to store" do
    before :each do
      @parent_video.stub!(:thumbnail_position)
      @clipping.stub!(:tmp_path).and_return('/tmp')
    end
    
    it "set_as_default should upload default clipping to store" do
      Store.should_receive(:set).with("foo.jpg", '/tmp')
      Store.should_receive(:set).with("foo_thumb.jpg", '/tmp')
      @clipping.set_as_default
    end

    it "upload_to_store should upload clipping to store with position" do
      Store.should_receive(:set).with("foo_40.jpg", '/tmp')
      Store.should_receive(:set).with("foo_40_thumb.jpg", '/tmp')
      @clipping.upload_to_store
    end

  end

  describe "capture" do
    before :each do
      @video_file = 'video'
      @video.stub!(:tmp_filepath).and_return(@video_file)
      @clipping_file = 'foo'
      @clipping.stub!(:public_filepath).and_return(@clipping_file)
      @inspector = mock(RVideo::Inspector)
      RVideo::Inspector.stub!(:new).with(:file => @video_file, :ffmpeg_binary => $FFMPEG).and_return(@inspector)
      File.stub!(:exists?).and_return(true)
    end
    
    it "should raise exception if the encoding is not available locally" do
      File.should_receive(:exists?).with(@video_file).and_return(false)
      
      lambda {
        @clipping.capture
      }.should raise_error
    end
    
    it "should capture clipping from encoding and save to public tmp dir" do
      @video.should_receive(:tmp_filepath).twice.and_return(@video_file)
      @clipping.should_receive(:public_filepath).and_return(@clipping_file)
      
      RVideo::Inspector.should_receive(:new).with(:file => @video_file, :ffmpeg_binary => $FFMPEG).and_return(@inspector)
      @inspector.should_receive(:capture_frame).with("40%", @clipping_file)
      
      @clipping.capture
    end
    
    it "should resize with position" do
      gd = mock(GDResize)
      gd.should_receive(:resize)
      GDResize.should_receive(:new).and_return(gd)
      
      @clipping.resize
    end
  end
  
  describe "changeable?" do
    it "should be true if panda configured for multiple thumbnails" do
      Panda::Config.should_receive(:[]).with(:choose_thumbnail).and_return(6)
      @clipping.should be_changeable
    end
    
    it "should be false if panda not configured for multiple thumbnails" do
      Panda::Config.should_receive(:[]).with(:choose_thumbnail).
        and_return(false)
      @clipping.should_not be_changeable
    end
  end
  
end
