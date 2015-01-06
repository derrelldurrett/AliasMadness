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
      add_to_players login
  end
end

Given /\A'([^']+)' visiting the '([^']+)' page\z/ do |login_name,page_name|
  # App delivers players to the Edit Bracket page, hence, 'I am visiting...'
  puts login_name+' will visit '+page_name
  steps %Q{
    Given '#{login_name}' who is logged in
    Given I am visiting '#{page_name}'
  }
end

Given /\AI am visiting '([^']+)'\z/ do |link|
  puts 'I will visit '+link
  click_link link
end

When /\AI visit the '([^']+)' page\z/ do |page_name|
  puts 'I will visit '+page_name+' page'
  visit path_to(page_name)
end

Given /\A'([^']+)' visiting the '([^']+)' page with all teams entered\z/ do |who,where|
  puts who+' will visit '+where
  steps %Q(
      Given The database is seeded
      Given The teams have already been entered
      Given '#{who}' visiting the '#{where}' page
      )
  sleep 12
end



