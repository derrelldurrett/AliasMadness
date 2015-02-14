Given %q('An invited player' logs in with all teams entered) do
  steps %q(
           Given The database is seeded
           Given The teams have already been entered
           Given 'An invited player' who is logged in
           )
end

Given %q('An invited player' logs in with all teams entered and players' games chosen) do
  steps %q(
           Given The database is seeded
           Given The teams have already been entered
           Given The players have been invited
           Given The players have entered their winning teams
           Given One of the players logs in
           )
end

Given %q('An invited player' should see the bracket in progress) do
  steps %q(
           Given The database is seeded
           Given The teams have already been entered
           Given The players have been invited
           Given The players have entered their winning teams
           Given The Admin has updated some games the first time
           Given 'An invited player' visiting the 'Edit Bracket' page
          )
end

Given(/\A'([^']+)' visiting the '([^']+)' page with all player's games entered\z/) do |who, page_name|
  puts who+' will visit '+page_name
  case who
    when %q(An admin)
      steps %Q(
               Given The database is seeded
               Given The teams have already been entered
               Given The players have been invited
               Given The players have entered their winning teams
               Given 'An Admin' visiting the 'Edit Bracket' page
               )
    when %q(An invited player)
      steps %q(
               Given 'An invited player' logs in with all teams entered and players' games chosen
               )
  end
end

Given %q(The players have been invited) do
  create_the_players
end

Given %q(The players have entered their winning teams) do
  get_players.each do |player|
    enter_players_bracket_choices_and_save_bracket(player)
  end
end

Given %q(One of the players logs in) do
  login_as_player get_players.first
end

When /\A'([^']+)' enters the winner for game '([^']+)'\z/ do |who,label|
  # case who
  #   when %q(An admin)
  game_labeled= game_by_label label.to_s
  enter_game_winner game_labeled
  #   else
  #     game_labeled= game_by_label label.to_s
  #     enter_game_winner game_labeled
  # end
end

Then /\AThe game labeled '([^']+)' should display correctly\z/ do |label|
  # FIXME incomplete-- doesn't test the labeled game for the correct selection
  label = label.to_s
  game_labeled= game_by_label label
  descendant_label= get_descendant_label(label)
  within(build_game_css descendant_label) do
    puts 'Checking '+label #+%q('s descendant, )+descendant_label.to_s+
    #          ', expecting participant '+game_labeled[:winner][:new_name]
    page.has_select?(GAME_WINNER_CSS, {with_options: game_labeled[:winner][:new_name]})
  end
end

When %q(An invited player enters the winners for the games) do
  63.downto(1).each do |label|
    steps %Q(When 'An invited player' enters the winner for game '#{label.to_s}')
    sleep 4
  end
  click_button('Submit Your Bracket')
  sleep 10
  visit path_to('Edit Bracket')
  sleep 5
end

Then %q(The games should display correctly) do
  63.downto(2).each do |label| # stop at 2 because 1 has no descendant!
    steps %Q(Then The game labeled '#{label.to_s}' should display correctly)
    sleep 1
  end
end

Then %q(The database should reflect the game choices) do
  verify_players_games logged_in_player.id
end

When %q(I view my bracket) do
  visit(current_path) # as long as Players have only one page....
  sleep 4
end

Then(/\AI should not be able to change '([^']+)' to '([^']+)'\z/) do |team_name, non_participating_team|
  attempt_to_change_a_team_name_as_a_player(team_name, non_participating_team)
end

When /\AThe Admin has updated some games the (\w+) time\z/ do |which_time|
  if which_time=='first'
    puts 'locking players brackets'
    lock_players_brackets
  end
  pick_game_winners_as_admin(ADMINS_LABEL_BLOCK[WHICH_TIME[which_time.to_sym]])
end

Then %q(the invited players scores should be calculated) do
  update_players_scores Admin.get.bracket
end

Then /\Athe '([^']+)' page should reflect the (\w+) standings\z/ do |page_name, which_time|
  visit path_to(page_name)
  sleep 3
  verify_displayed_standings compute_expected_standings which_time
end

Then %q('An invited player' should see the correct choices in green and the incorrect choices in red the $nth time) do |nth|
  puts %Q(checking user #{@user.name})
  reference_bracket= games_by_label(Admin.get.bracket)
  players_bracket= games_by_label(@user.bracket)
  ADMINS_LABEL_BLOCK[WHICH_TIME[nth.to_sym]].each do |l|
    label = l.to_s
    # save_and_open_page %Q(page_#{label}.html)
    within(build_game_css(label)) do
      r_game= reference_bracket[label]
      p_game= players_bracket[label]
      expect(r_game.winner).not_to be_nil
      if p_game.winner==r_game.winner
        puts %Q(expect #{label} to have green)
        page.has_css?('td.green_winner_state')
        save_and_open_page page_with_label_and_color(label, 'green')
        expect(find('td.green_winner_state').value).to eql(p_game.winner.label)
      else
        puts %Q(expect #{label} to have red)
        page.has_css?('td.red_winner_state')
        save_and_open_page page_with_label_and_color(label, 'red')
        expect(find('td.red_winner_state').value).not_to eql(r_game.winner.label)
      end
    end
  end
end

