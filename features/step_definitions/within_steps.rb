def invite_player(name,email)
  fill_in 'Name', with: name
  fill_in 'Email', with: email
  click_button('Invite Player')
end

def login_as_admin
  admin = Admin.get
  email = admin.email
  password = 'foobaer'
  link = login_path(email: email)
  visit link
  fill_in 'Password', with: password
  click_button('Login')
  click_link('Invite Player')
end
