When 'I view scenarios' do
  steps %q(Given 'an invited player' who is logged in)
  click_link 'View Scenarios'
  save_and_open_page
  expect(page).to have_content('Scenario List')
end

