Given /^I am signed in as "([^\"]*)"$/ do |email_and_password|
  email, password = email_and_password.split("/")
  Given %{I am signed up as "#{email}/#{password}"}
  When %{I go to the sign in page}
  And %{I sign in as "#{email}/#{password}"}
end

Then /^I should be logged out$/ do
  response.should have_selector("a[href='#{login_path}']")
end

Then /^I should be logged in$/ do
  response.should have_selector("a[href='#{logout_path}']")
end
