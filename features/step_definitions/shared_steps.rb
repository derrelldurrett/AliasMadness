Given %q(The database is seeded) do
  require_relative(%q(../../db/seeds))
  seed_admin
end

Given /\A'([^']+)' who is logged in\z/ do |login|
  user = /(?i:admin)/.match login
  if user.nil?
    # Do something to log in a user who is not admin
  else
    steps %q{
      Given The database is seeded
    }
    login_as_admin
  end
end

Given /\A'([^']+)' visiting the '([^']+)' page\z/ do |login_name,page_name|
  steps %Q{
    Given '#{login_name}' who is logged in
    Given I click the '#{page_name}' link
  }
  store_team_data
end

When /I visit the '([^'])+' page/ do |page_name|
  visit path_to(page_name)
end
