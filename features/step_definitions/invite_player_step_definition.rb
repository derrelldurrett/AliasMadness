# This file and its step definitions need to be broken into two files,
# or I need to learn how to rename step_definition files.
# Or maybe I need to learn what the rules are for step_definition file names.

Given %q(An admin who is logged in) do
  login_as_admin
end

Given /A player with name '([^']+)' and email '([^']+)' already exists/ do |name,email|
  invite_player(name,email)
end

When %q(A Player does not exist and I enter a his data) do
  user = User.find_by_name('derrell')
  unless user.nil?
    id = user.id
    User.delete(id)
  end
  invite_player('derrell','dd@fake.com')
end

Then %q(I should have a new player in the database) do
  User.find_by_name('derrell').should_not be_nil
end

Then %q(I should see a message that my Player was created) do
  page.should have_content(%q(User 'derrell' created))
end

Then %q(I should see the page to invite a new Player) do
  page.should have_button 'Invite Player'
end

Then %q(I should send an email to the Player with a link for the Player to log in) do
  mailbox_for('dd@fake.com').size.should == parse_email_count(1)
end

When %q(I invite an existing player) do
  invite_player('derrell','dd@fake.com')
end

Then /\AI should see the "([^"]+)" error\z/ do |error|
  #save_and_open_page
  page.should have_content error
end
