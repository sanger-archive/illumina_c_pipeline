Then /^I should be in the tag selection page$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be in the homepage$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be in the tube page$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^(?:|I )wait (\d+) seconds?$/ do |seconds|
  sleep(seconds.to_i)
end

When /^I enter with a "([^"]*)" plate$/ do |arg1|
  fill_in("Plate or Tube Barcode", :with => "1220000010734")

  # For the moment, because I prefer not to touch the actual JS code
  page.execute_script("$('.show-my-plates').val(false)")
  page.execute_script("$('form').submit()")
end

Then /^I am presented with a screen allowing me to create a tagged plate$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see a "([^"]*)" plate$/ do |arg1|
  assert page.has_content?(arg1)
end

Then /^I should see that the plate is in "([^"]*)" state$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I should be able to create a "([^"]*)" plate$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I create the next plate$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be in a plate page$/ do
  assert true
end

When /^I select "([^"]*)" from Tags selection$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I click on "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I am in a plate page$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I move to the next state$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I change state to started$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I am in the homepage$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see a plate has been changed to "([^"]*)" state$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I enter with the last plate shown$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see that the plate is in started state$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I change state to "([^"]*)" state$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I should see that the plate is in passed state$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be able to create a "([^"]*)" tube$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I create the next tube$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I am in the tube page$/ do
  pending # express the regexp above with the code you wish you had
end
