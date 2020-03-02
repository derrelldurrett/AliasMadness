When /\AI click the '([^']+)' link\z/ do |link_name|
  click_link link_name
end

NODE_64_CSS = 'td.team[data-node="64"]'
NODE_97_CSS = 'td.team[data-node="97"]'

Then %q(I should see the initial bracket) do
  team_1_node = find(NODE_64_CSS)
  within(team_1_node) do
    find(INPUT_TEAM_CSS).value.should have_content 'Team 1'
  end
  team_64_node = find(NODE_97_CSS)
  within(team_64_node) do
    find(INPUT_TEAM_CSS).value.should have_content 'Team 64'
  end
end

When /\AI change the name of the team '([^']+)' to '([^']+)'\z/ do |old_name,new_name|
  change_a_team_name_as_admin(old_name, new_name)
end

When %q(I change the names of the teams) do
  enter_team_names_as_admin
end


INPUT_TEAM_CSS = 'input.team_name'
Then(/\AI should see '([^']+)' on the '([^']+)' page in place of '([^']+)', (\w+)(,\s.+)?\z/) do |new_item, link, old_item, lock_state, reload_page|
  will_reload= reload_page=='without reloading'
  visit(path_to link) if will_reload
  is_locked= lock_state=='locked'
  team_css=construct_team_css_node_name(lookup_label_by_old_name(old_item))
  if is_locked
    expect(find(team_css)).to have_content new_item
  else
    within(team_css) do
      # save_and_open_page
      expect(find(INPUT_TEAM_CSS).value).to have_content new_item
    end
  end
end

NONEXISTENT_TEAM='CSU-Pueblo'
Then %q(The team names should not be editable) do
  team_data.each do |t|
    steps %Q{
      Then I should not be able to change '#{t[:new_name]}' to '#{NONEXISTENT_TEAM}'
      }
  end
end

Then(/\AThe team '([^']+)' should be the '([^']+)' for '([^']+)'\z/) do |new_team_attr_val, team_attr, old_team_attr_val|
  team = Team.where(id: look_up_team_id_by_original_data(old_team_attr_val)).first.reload
  expect(team).not_to be_nil
  expect(team.send(team_attr)).to eq(new_team_attr_val)
end

Then 'The teams should have the new names' do
  #save_and_open_page
  team_data.each do |t|
    steps %Q{
      Then The team '#{t[:new_name]}' should be the 'name' for '#{t[:old_name]}'
      }
  end
end

Then /\AAn admin should see the new names on the '([^']+)' page\z/ do |page_name|
  visit path_to(page_name)
  team_data.each do |t|
    steps %Q{
      Then I should see '#{t[:new_name]}' on the '#{page_name}' page in place of '#{t[:old_name]}', locked, without reloading
      }
  end
end