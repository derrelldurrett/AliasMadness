Given %q(The database is seeded) do
  seed_database
end

Given /\A'([^']+)' who is logged in\z/ do |login|
  case login
    when /(?i:admin)/
      login_as_admin
  when /(?i:(\binvited player))/
    players = User.players
    @login = (players.nil? or players.empty?) ? create_a_player : players.first
    login_as_player @login
  end
end

Given /\A'([^']+)' visiting the '([^']+)' page\z/ do |login_name,page_name|
  # App delivers players to the Edit Bracket page, hence, 'I am visiting...'
  puts login_name+' will visit '+page_name
  steps %Q{
    Given '#{login_name}' who is logged in
    Given I am visiting '#{page_name}'
  }
  click_button 'Update Bracket' if login_name == 'admin'
end

Given /\AI am visiting '([^']+)'\z/ do |link|
  puts 'I will visit '+link
  click_link link
end

When /\AI visit the '([^']+)' page\z/ do |page_name|
  puts 'I will visit '+page_name+' page'
  visit path_to(page_name)
end

When %q(click the button to set the names) do
  click_button 'Set Team Names'
  sleep 5
  visit path_to('Edit Bracket')
  sleep 5
end

Given /\A'([^']+)' visiting the "([^"]+)" page with all teams entered\z/ do |who,where|
  puts who+' will visit '+where
  steps %Q(
      Given The database is seeded
      Given The teams have already been entered
      Given '#{who}' visiting the '#{where}' page
      )
  sleep 12
end

When /\AClicks '([^']+)'\z/ do |link|
  click_button link
end

Given %q(The teams have already been entered) do
  team_data.each do |t|
    team= Team.where(name: t[:old_name]).first
    if team.nil?
      team= Team.where(name: t[:new_name]).first
      next unless team.nil?
      puts %Q(Team not found under old (#{t[:old_name]}) or new name (#{t[:new_name]}))
      Team.all.each do |t|
        puts "Team: #{t.name} (#{t.id})"
      end
      next
    end
    result= team.update_attribute :name, t[:new_name]
    redo unless result
  end
  lock_team_names
  sleep 1
end
