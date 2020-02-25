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
  brackets = User.where(role: :player, bracket_locked: false)
  puts "Unlocked player brackets: #{brackets.length}"
  expect(brackets).to be_empty
end
