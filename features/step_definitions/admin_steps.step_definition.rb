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
  sleep 15
  brackets = User.where(role: :player, bracket_locked: false)
  puts "Unlocked player brackets: #{brackets.length} out of #{User.where(role: :player).count}"
  expect(brackets).to be_empty
end
