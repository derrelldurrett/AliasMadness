Given %q{The Admin's email address} do
  admin = Admin.get
  @email = admin.email
end

Given %q(The Admin's email address and password) do
  admin = Admin.get
  @email = admin.email
  @password = ENV['ALIASMADNESS_PASSWORD']
end

Then 'The players brackets should be locked' do
  brackets = User.where.not(bracket_locked: false)
  expect(brackets).to be_empty
end
