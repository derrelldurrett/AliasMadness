Given %q(The database is seeded) do
  require_relative(%q(../../db/seeds))
  seed_admin
  store_team_data
end

Given /\A'([^']+)' who is logged in\z/ do |login|
  case login
    when /(?i:admin)/
      steps %q{
        Given The database is seeded
      }
      login_as_admin
    when /(?i:(\binvited player))/
      login = FactoryGirl.create(:player)
      login_as_player login
  end
end

Given /\A'([^']+)' visiting the '([^']+)' page\z/ do |login_name,page_name|
  # App delivers players to the Edit Bracket page, hence, 'I am visiting...'
  steps %Q{
    Given '#{login_name}' who is logged in
    Given I am visiting '#{page_name}'
  }
end

Given /\AI am visiting '([^'])+'\z/ do |link|
  visit path_to(link)
end

When /I visit the '([^'])+' page/ do |page_name|
  visit path_to(page_name)
end

Given /\A'([^']+)' visiting the '([^']+)' page with all teams entered\z/ do |who,where|
  steps %Q(
      Given The database is seeded
      Given The teams have already been entered
      Given '#{who}' visiting the '#{where}' page
      )
  sleep 12
end

