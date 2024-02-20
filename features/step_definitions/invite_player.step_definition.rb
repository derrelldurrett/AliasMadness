# This file and its step definitions need to be broken into two files,
# or I need to learn how to rename step_definition files.
# Or maybe I need to learn what the rules are for step_definition file names.

Given /I am visiting the '([^']+)' page\z/ do |link_name|
  click_link link_name
end

Given /\AA player with name '([^']+)' and email '([^']+)' already exists\z/ do |name,email|
  invite_player name,email
end

When %q(A Player does not exist and I enter a his data) do
  user = User.where(name: 'derrell').first
  unless user.nil?
    id = user.id
    User.delete(id)
  end
  invite_player 'derrell','dd@fake.com'
end

Then %q(I should have a new player in the database) do
  player_name='derrell'
  User.where(name: player_name).should_not be_empty
  u= User.where(name: player_name).first
  u.role.should_not be_nil
  u= User.where(role: 'player').first
  u.should_not be_nil
  expect(u.name).to eq(player_name)
  expect(u.role).to eq('player')
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
  invite_player 'derrell','dd@fake.com'
end

Then /\AI should see the "([^"]+)" error\z/ do |error|
  page.should have_content error
end
