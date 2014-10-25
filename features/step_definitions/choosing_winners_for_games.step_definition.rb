When /\A'([^']+)' enters the winner for game '([^']+)'\z/ do |who,label|
    case who
      when %q(An admin)
        game_labeled= game_by_label label.to_s
        enter_game_winner game_labeled
      else
        game_labeled= game_by_label label.to_s
        enter_game_winner game_labeled
    end
end

Then /\AThe game labeled '([^']+)' should display correctly\z/ do |label|
  label = label.to_s
  game_labeled= game_by_label label
  descendant_label= get_descendant_label(label)
  within(build_game_css descendant_label) do
    puts 'Checking '+label+%q('s descendant, )+descendant_label.to_s+
             ', expecting participant '+game_labeled[:winner][:new_name]
    page.has_select?(GAME_WINNER_CSS, with_options: game_labeled[:winner][:new_name])
  end
end

When %q(An invited player enters the winners for the games) do
  (1..63).reverse_each do |label|
    steps %Q(When 'An invited player' enters the winner for game '#{label.to_s}')
    sleep 4
  end
  click_button('submit_games')
end

Then %q(The games should display correctly) do
  (2..63).reverse_each do |label| # stop at 2 because 1 has no descendant!
    steps %Q(Then The game labeled '#{label.to_s}' should display correctly)
    sleep 1
  end
end

Then %q(The database should reflect the game choices) do
  check_players_games
end