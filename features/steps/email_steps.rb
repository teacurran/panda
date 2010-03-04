Then /^"([^\"]+)" should receive the email:$/ do |email_address, table|
  find_email(email_address, table).should_not be_nil
end
