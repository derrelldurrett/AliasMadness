Given "'An invited player' logs in with all teams entered" do
  steps "
           Given The database is seeded
           Given The teams have already been entered
           Given 'An invited player' who is logged in
           "
end

Given "'An invited player' logs in with all teams entered and other players invited" do
  steps "
           Given The database is seeded
           Given The teams have already been entered
           Given The players have been invited
           Given 'An invited player' who is logged in
           "
end

Given /\A'([^']+)' logs in with all teams entered and players' games chosen\z/ do |who|
  steps "
           Given The database is seeded
           Given The teams have already been entered
           Given The players have been invited
           Given The players have entered their winning teams
           Given '#{who}' who is logged in
        "
end

Given "'An invited player' should see the bracket in progress" do
  steps "
           Given The database is seeded
           Given The teams have already been entered
           Given The players have been invited
           Given The players have entered their winning teams
           Given The Admin has updated some games the first time
           Given 'An invited player' visiting the 'Edit Bracket' page
          "
end

Given(/\A'([^']+)' visiting the '([^']+)' page with all players' games entered\z/) do |who, page_name|
  puts who + ' will visit ' + page_name
  case who
  when 'An admin'
    steps %(
               Given The database is seeded
               Given The teams have already been entered
               Given The players have been invited
               Given The players have entered their winning teams
               Given 'An Admin' visiting the '#{page_name}' page
               )
  when 'An invited player'
    steps "
               Given 'An invited player' logs in with all teams entered and players' games chosen
               "
  else
    raise "Bad feature spec!"
  end
end

Given 'The pool is in progress' do
  steps "
           Given The database is seeded
           Given The teams have already been entered
           Given The players have been invited
           Given The players have entered their winning teams
           Given The Admin has locked the players' brackets
           Given The Admin has updated some games the first time
         "
end

Given 'The pool is in progress with a specific set of players and teams' do
  admin, _games_remaining = init_brackets(10) #use the smallest scenario
  lock_players_brackets
  ScenarioFactory.new.build_scenarios_without_delay(admin) # do it inline
end

Given 'The players have been invited' do
  create_the_players
end

Given 'The players have entered their winning teams' do
  User.players.each do |player|
    complete_brackets(player)
  end
end

Given 'One of the players logs in' do
  login_as_player User.players.first
end

When /\A'([^']+)' enters the winner for game '([^']+)'\z/ do |_who, label|
  game_labeled = game_by_label label.to_s
  enter_game_winner game_labeled
end

Then /\AThe game labeled '([^']+)' should display correctly\z/ do |label|
  label = label.to_s
  game_labeled = game_by_label label
  game_css = build_game_css(label)
  within(game_css) do
    expect(page).to have_select("game_#{label}", selected: game_labeled[:winner][:new_name])
  end
  descendant_label = get_descendant_label(label)
  descendant_game_css = build_game_css(descendant_label)
  within(descendant_game_css) do
    expect(page).to have_select("game_#{descendant_label}", with_options: [game_labeled[:winner][:new_name]])
  end
end

When 'An invited player enters the winners for the games' do
  63.downto(1).each do |label|
    steps %(When 'An invited player' enters the winner for game '#{label}')
  end
  click_button('Submit Your Bracket')
  sleep 1
  visit path_to('Edit Bracket')
  sleep 1
end

When "An invited player's winners for the games have all been entered" do
  complete_brackets(User.players.first)
end

Then 'The games should display correctly' do
  63.downto(2).to_a.sample(10).each do |label| # stop at 2 because 1 has no descendant!
    steps %(Then The game labeled '#{label}' should display correctly)
    sleep 1
  end
end

Then 'The database should reflect the game choices' do
  verify_players_games logged_in_player.id
end

When /I view "([^"]+)"/ do |which_bracket|
  case which_bracket
  when /another/
    @other_id = User.players.each_other_id(@user.id).to_a.sample
    other = User.find(@other_id)
    # can't use this for when there's a score without computing it.
    click_link "#{other.name} == 0"
  else
    # do nothing
  end
  sleep 2
end

Then(/\AI should not be able to change '([^']+)' to '([^']+)'\z/) do |team_name, non_participating_team|
  attempt_to_change_a_team_name_as_a_player(team_name, non_participating_team)
end

Given "The Admin has locked the players' brackets" do
  lock_players_brackets
end

When /\AThe Admin has updated some games the (\w+) time\z/ do |which_time|
  case which_time
  when 'first'
    steps "Given The Admin has locked the players' brackets"
  else
    #do nothing
  end
  pick_game_winners_as_admin(ADMINS_LABEL_BLOCK[WHICH_TIME[which_time.to_sym]], false)
end

Then 'the invited players scores should be calculated' do
  update_players_scores Admin.get.bracket.reload
end

Then /\Athe '([^']+)' page should reflect the (\w+) standings\z/ do |page_name, which_time|
  visit path_to(page_name)
  sleep 2
  verify_displayed_standings compute_expected_standings which_time
end

Then /\A'An invited player' should see the correct choices in green and the incorrect choices in red the (\w+) time\z/ do |nth|
  steps "Given 'An invited player' who is logged in"
  reference_bracket = games_by_label(User.find_by_role(:admin).bracket)
  puts "reload page the #{nth} time."
  page.evaluate_script 'window.location.reload()' # wield a hammer, apparently.
  players_bracket = games_by_label(logged_in_player.bracket)
  is_eliminated = {}
  check_winners_correctly_listed(is_eliminated, nth, players_bracket, reference_bracket)
  check_losers_shown_in_red(is_eliminated, players_bracket)
end

Then "An admin should see the player's entry in the leader board turn green" do
  steps "Given 'An Admin' visiting the 'Edit Bracket' page"
  verify_player_is_green_state User.players.first
end

When "I change a game's winner" do
  # 1) select a game that's not game 1
  # 2) change the winner
  @players_bracket = logged_in_player.bracket
  games = games_by_label(@players_bracket)
  ancestor_of_label_to_check = '35'
  ancestor_of_game_to_check = games[ancestor_of_label_to_check]
  @label_to_check = get_descendant_label(ancestor_of_label_to_check)
  @previous_winner = change_winner(ancestor_of_game_to_check)
end

Then "The subsequent games should display 'Choose winner...'" do
  until @label_to_check.nil?
    puts "checking game reset for player #{@user.id} and game #{@label_to_check}"
    winner_reset?(@label_to_check)
    @label_to_check = get_descendant_label(@label_to_check)
  end
end

Then 'I should not be able to change its games' do
  td_node_name = build_game_css('63')
  within(td_node_name) do
    expect(page).to have_selector(GAME_WINNER_CSS + '[disabled]')
  end
end