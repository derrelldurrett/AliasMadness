When 'I view scenarios' do
  steps %q(Given 'an invited player' who is logged in)
  click_link 'View Scenarios'
  expect(page).to have_content('Scenario List')
end

Then("I should see only Round {int} in two Scenarios and Round {int} and Round {int} in eight Scenarios") do |round_with_2, round_with_8_1, round_with_8_2|
  save_and_open_page
  [1,2].each do |scenario|
    expect(find("div.scenario#scenario_#{scenario}")).to have_content("Round #{round_with_2}")
    expect(find("div.scenario#scenario_#{scenario}")).not_to have_content("Round #{round_with_8_2}")
  end
  3.upto(10).each do |scenario|
    expect(find("div.scenario#scenario_#{scenario}")).to have_content("Round #{round_with_8_1}")
    expect(find("div.scenario#scenario_#{scenario}")).to have_content("Round #{round_with_8_2}")
  end
end

Then("I should see Team {int} in exactly two Round {int} Scenarios") do |team_id, round_id|
  count = 0
  1.upto(10).each do |scenario|
    scenario_div = find("div.scenario#scenario_#{scenario}")
    if scenario_div.has_text?("Round #{round_id}") and scenario_div.has_text?("Team #{team_id}")
      count += 1
    end
  end
  expect(count).to eql 2
end
