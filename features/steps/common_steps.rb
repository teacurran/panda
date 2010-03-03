When /^I request the login page$/ do
  webrat.get "/login"
end

Then /^I should receive a "([^\"]*)" response$/ do |status|
  webrat.response.status.should eql(status.to_i)
end

Then /^I should receive a "([^\"]*)" response with message "([^\"]*)"$/ do |status,message|
  webrat.response.status.should eql(status.to_i)
  webrat.response.instance_variable_get(:@message).should contain(message)
end

Then /^I start the debugger$/ do
  debugger
  puts
end
