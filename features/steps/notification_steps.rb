
When /^I have uploaded (?:a|the) video file(?: \"(.*)\")?$/ do |file|
  upload_video(file || "default_video.mov")
end

Then /^I should receive the "([^\"]*)" notification$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^the video file begins encoding$/ do
  Video.encode_next(
    :begin => lambda { |video|
      NotificationQueue.add_video(video)
    },
    :failure => lambda { |video|
      NotificationQueue.add_video(vide)
    },
    :success => lambda { |video|
      NotificationQueue.add_video(video)
    }
  )
end

When /^the video file finishes encoding$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I have received the notification "([^\"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^the video cannot encode$/ do
  pending # express the regexp above with the code you wish you had
end
