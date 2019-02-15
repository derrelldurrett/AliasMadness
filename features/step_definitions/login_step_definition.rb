Given %q{The Admin's email address} do
  admin = Admin.get
  @email = admin.email
end

Given %q{a link to the login page with the email as the parameter} do
  @link = login_path(email: @email)
end

Given %q{an existing database seeded with the Admin's data} do
  # which is satisfied by the Admin.get being successful
end

Then %q{the page should contain the email address in the 'email' field} do
  expect(page).to have_selector('label')
  expect(page).to have_content('Email')
  # save_and_open_page
  find_field('Email').value.should eq(@email)
end

Then %q{the 'password' field should be empty} do
  expect(page).to have_selector('label')
  @password = ENV['ALIASMADNESS_PASSWORD']
  @link = login_path(email: @email)
end

When %q(I visit the login page, enter the password, and click 'Login') do
  visit @link
  expect(page).to have_content('Password')
  find_field('Password').value.should be_nil
  fill_in  'Password', with: @password
  click_button 'Login'
end

Given %q(The Admin's email address and password) do
  admin = Admin.get
  @email = admin.email
  @password = ENV['ALIASMADNESS_PASSWORD']
end

Then %q(I should have a choice between creating Players, creating Brackets, choosing winners for games, or sending a message about the state of the pool, depending on the time at which I visit the page.) do
  expect(page).not_to have_content('Invalid email/password')
  expect(page).to have_content('Invite Player')
  expect(page).to have_content('Edit Bracket')
  expect(page).to have_content('Send Message')
  expect(page).to have_content('View Scenarios')
  expect(page).to have_content('Contact')
end

Given %q(an invalid or missing email address) do
  @email= 'foo@notactually.com'
end

Given %q(a link to the login page containing the email) do
  @link = login_path(email: @email)
end

Then %q(the returned page should be ‘404’) do
  #save_and_open_page
  expect(page).to have_title(%q(The page you were looking for doesn't exist (404)))
end
