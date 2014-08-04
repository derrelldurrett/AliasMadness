When /\AI click the '([^']+)' link\z/ do |link_name|
  click_link link_name
end

NODE_64_CSS = 'td.team[data-node="64"]'
NODE_97_CSS = 'td.team[data-node="97"]'
INPUT_TEAM_CSS = 'input#bracket_teams_attributes_name'
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
  node_name = construct_team_css_node_name lookup_label_by_team_name(old_name)
  within(node_name) do
    # input_box = find(INPUT_TEAM_CSS)
    # input_box.send_keys(new_name)
    # input_box.set(new_name)
    # page.driver.action.click(input_box).perform
    # # # save_and_open_page
    # input_box.click
    # fill_in INPUT_TEAM_CSS, with: new_name
    # tab is keycode 9; enter is keycode 13 :
    # var e = $.Event('keypress');
    # e.which = 13;
    fill_and_click_script =
        %Q(
         $('#{node_name} #{INPUT_TEAM_CSS}').focus().val('#{new_name}');
         $('#{node_name} #{INPUT_TEAM_CSS}').trigger('change');
       )
    #    puts fill_and_click_script+"\n"
    page.driver.execute_script(fill_and_click_script)
    # input_box.send_string_of_keys(:return)
    # input_box.native.send_keys("\x0D")
    # Capybara::RackTest::Form.new(page.driver, input_box).submit name: nil
  end
end


When %q(I change the names of the teams) do
  team_data.each do |t|
    steps %Q{
      When I change the name of the team '#{t[:old_name]}' to '#{t[:new_name]}'
      }
    sleep 5
  end
  sleep 20

  # save_and_open_page
end

Then(/\AI should see '([^']+)' on the '([^']+)' page in place of '([^']+)'\z/) do |new_item, link, old_item|
  click_link link
  # save_and_open_page
  within(construct_team_css_node_name(lookup_label_by_team_name old_item)) do
    expect(find(INPUT_TEAM_CSS).value).to have_content new_item
  end
end

Then(/\AThe team '([^']+)' should be the '([^']+)' for '([^']+)'\z/) do |new_team_attr_val, team_attr, old_team_attr_val|
  team = Team.find_by_id look_up_team_id_by_original_data(old_team_attr_val)
  expect(team.send(team_attr)).to eq(new_team_attr_val)
end

Then %q(The teams should have the new names) do
  team_data.each do |t|
    steps %Q{
      Then The team '#{t[:new_name]}' should be the 'name' for '#{t[:old_name]}'
      }
  end
end

Then /\AI should see the new names on the '([^']+)' page\z/ do |page_name|
  team_data.each do |t|
    steps %Q{
      Then I should see '#{t[:new_name]}' on the '#{page_name}' page in place of '#{t[:old_name]}'
      }
  end
end