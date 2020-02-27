When 'I view scenarios' do
  steps %q(Given 'an invited player' who is logged in)
  click_link 'View Scenarios'
  expect(page).to have_content('Scenario List')
end

Then("I should see only Round {int} in two Scenarios and Round {int} and Round {int} in eight Scenarios") do |int, int2, int3|
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I should see Team {int} in exactly two Round {int} Scenarios") do |int, int2|
  pending # Write code here that turns the phrase above into concrete actions
end
