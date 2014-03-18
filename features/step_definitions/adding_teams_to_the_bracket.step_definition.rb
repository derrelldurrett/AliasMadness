When /\AI click the '([^']+)' link\z/ do |link_name|
  click_link link_name
end

Then %q(I should see the initial bracket) do
  within('form#edit_team_64') do
    find('input#team_name').value.should have_content 'Team 1'
  end
  within('form#edit_team_31') do
    find('input#team_name').value.should have_content 'Team 64'
  end
end


When /\AI change '([^']+)' to '([^']+)' and hit return\z/ do |initial_team,correct_team|
  within('form#edit_team_64') do
    fill_in 'team_name', with: correct_team+%Q(\n)
  end
end

Then(/\AI should see '([^']+)' on the '([^']+)' page\z/) do |new_item, link|
  click_link link
  save_and_open_page
  within('form#edit_team_64') do
    find('input#team_name').value.should have_content new_item
  end
end
