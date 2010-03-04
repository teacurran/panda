require 'ftools'

When /^I have uploaded (?:a|the) non-video file(?: \"(.*)\")?$/ do |file|
  upload_video(file || "non-video.jpg")
end

When /^I have uploaded (?:a|the) bad video file(?: \"(.*)\")?$/ do |file|
  upload_video(file || "unuploadable.mov")
end

When /^I have uploaded (?:a|the) video file(?: \"(.*)\")?$/ do |file|
  if upload_video(file || "default_video.mov").body =~ /\"video_file_id\":\"([^\"]+)\"/
    video_file_id = $1
    @video = Video.find(video_file_id)
  else
    raise "Response from uploading video did not include video_file_id!\n#{webrat.response.body}"
  end
end

When /^I have uploaded a video file that cannot encode$/ do
  When "I have uploaded the video file \"default_video.mov\""
  # Black magic! A little sleight of hand action here...
  # Secretly switching the video file with a BAD one!
  uri = URI.parse(@video.url)
  filename = "public/#{uri.path}"
  File.should exist(filename)
  File.cp("features/fixtures/unuploadable.mov", filename)
end

When /^I have uploaded a video file that will encode$/ do
  When "I have uploaded the video file \"default_video.mov\""
end

Then /^I should receive the "([^\"]*)" notification$/ do |state|
  Notification.pending_notifications.any? do |n|
    n.state == state && n.uri == @video.state_update_url
  end.should eql(true)
end

When /^the video file encodes$/ do
  last_video = nil
  loop do
    # puts "Encoding..."
    video = Video.encode_next(
        :processing => lambda { |video|
          Notification.add_video(video)
        },
        :error => lambda { |video|
          Notification.add_video(video)
        },
        :success => lambda { |video|
          Notification.add_video(video)
        }
      )
    break unless video
    if video == last_video
      raise("Encoding the same video twice!\n#{video.inspect}")
    else
      # puts video.inspect
    end
    last_video = video
  end
end

When /^the encoding should fail$/ do
  @video.encodings.each do |enc|
    # debugger
    enc.status.should eql("error")
    uri = URI.parse(enc.url)
    File.should_not exist("public/#{uri.path}")
  end
end

When /^the encoding should succeed$/ do
  @video.encodings.each do |enc|
    enc.status.should eql("success")
    uri = URI.parse(enc.url)
    File.should exist("public/#{uri.path}")
  end
end

When /^the video cannot encode$/ do
  pending # express the regexp above with the code you wish you had
end
