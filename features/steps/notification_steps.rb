Given /^the following notifications have been queued:$/ do |table|
  table.hashes.each do |attrs|
    n = Notification.create(attrs)
    n.should_not be_new
  end
end

When /^the notifier runs$/ do
  Notification.notify_all!
end

Then /^I should receive the "([^\"]*)" notification$/ do |state|
  Notification.pending_notifications.any? do |n|
    n.state == state && n.uri == @video.state_update_url
  end.should eql(true)
end

