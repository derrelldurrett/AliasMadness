Then 'The players brackets should be locked' do
  brackets = User.where.not(bracket_locked: false)
  expect(brackets).to be_empty
end