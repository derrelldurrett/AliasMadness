ADMINS_CHANGED_LABELS = 63.downto(31)

def invite_player(name, email)
  fill_in 'Name', with: name
  fill_in 'Email', with: email
  click_button('Invite Player')
end

def login(email, password)
  link = login_path(email: email)
  visit link
  save_and_open_page
  fill_in 'Password', with: password
  click_button('Login')
end

def login_as_admin
  admin = Admin.get
  @user= admin
  email = admin.email
  password = 'foobaer'
  login(email, password)
end

def login_as_player(player)
  email= player.email
  password= player.remember_for_email
  @logged_in_player= @user= player
  login(email, password)
end

# go look at the TDD talk (by @moonmaster9000 on Twitter)
# to understand how to use the begin block form
def store_team_data
  @look_up_team_id_by_original_data = init_team_lookup_data
end

def init_team_lookup_data
  ret= Hash.new
  Team.all.each do |t|
    ret[t.name]=t.id
  end
  ret
end

def look_up_team_id_by_original_data(data)
  @look_up_team_id_by_original_data[data]
end

def construct_team_css_node_name(label)
  %Q(td.team[data-node="#{label}"])
end

def build_game_css(label)
  %Q(td.game[data-node="#{label}"])
end

def path_to(page_name)
  case page_name
    when /\Alogin\z/i
      login_path(email: @email)
    when /Edit Bracket/i
      puts 'Visiting '+page_name+' for user '+@user.id.to_s
      user_path(id: @user.id)
    else
      raise %Q{Can't find path_to entry for #{page_name}!}
  end
end

def change_a_team_name_as_admin(old_name, new_name)
  node_name = construct_team_css_node_name lookup_label_by_old_name(old_name)
  within(node_name) do
    fill_and_click_script =
        %Q(
         $('#{node_name} #{INPUT_TEAM_CSS}').focus().val('#{new_name}');
         $('#{node_name} #{INPUT_TEAM_CSS}').trigger('change');
       )
    page.driver.execute_script(fill_and_click_script)
  end
end

def enter_team_names_as_admin
  team_data.each do |t|
    change_a_team_name_as_admin t[:old_name], t[:new_name]
    sleep 4
  end
  sleep 15
end

GAME_WINNER_CSS='select.game_winner'

def enter_game_winner(game)
  td_node_name= build_game_css(game[:label])
  within(td_node_name) do
    choose_winner_script = %Q(
      $('#{td_node_name} #{GAME_WINNER_CSS}').val('#{game[:winners_label]}');
      $('#{td_node_name} #{GAME_WINNER_CSS}').focus().trigger('change');
      )
    page.driver.execute_script(choose_winner_script)
  end
end

def verify_players_games(id)
  bracket= Bracket.find_by_user_id id
  players_games= bracket.games.sort_by { |g| g.label.to_i }
  players_games.reverse_each do |p|
    expect(p.winner).not_to be_nil
    expect(p.winner.name).to eq(game_by_label(p.label)[:winner][:new_name])
  end
end

N_PLAYERS= 5

def team_data_by_label(label)
  @team_data_by_label||= hash_by_label Team.all
  @team_data_by_label[label]
end

def players_games_entered
  N_PLAYERS.times do
    player = FactoryGirl.create(:player)
    add_to_players player
    bracket= Bracket.find_by_user_id player.id
    choose_games_for_bracket bracket
    save_mock_bracket player
    verify_players_games player.id
  end
end

def games_by_label(bracket)
  @bracket_in_db||= Hash.new
  @bracket_in_db[bracket.id]||= Hash.new
  @bracket_in_db[bracket.id][:games_by_label]||= hash_by_label (Game.find_all_by_bracket_id bracket.id)
end

def choose_games_for_bracket(bracket, labels=63.downto(1), reset_game_data=true)
  reinit_game_data if reset_game_data
  bracket_games_by_label = games_by_label(bracket)
  labels.each do |label|
    g= bracket_games_by_label[label.to_s]
    winning_team = team_data_by_label(game_by_label(label)[:winners_label])
    g.update_attributes!({winner: winning_team})
  end
end

def hash_by_label(labeled_entities)
  ret= Hash.new
  labeled_entities.each { |e| ret[e.label]= e }
  ret
end

def pick_game_winners_as_admin(labels, reset_game_data=true)
  admin = Admin.get
  admin_bracket= admin.bracket
  choose_games_for_bracket admin_bracket, labels, reset_game_data
  save_mock_bracket admin
end

def add_to_players(player)
  @players||= Array.new
  @players<< player
end

def get_players
  @players
end

def compute_expected_standings
  admin_games= @mock_brackets_by_player['admin']
  standings= Hash.new
  @mock_brackets_by_player.each do |p, p_data|
    next if p== 'admin'
    p_data[:score]= 0
    ADMINS_CHANGED_LABELS.each do |l|
      if p_data[:games][l][:winners_label]== admin_games[:games][l][:winners_label]
        p_data[:score]+= admin_games[:games][l][:winner][:seed].to_i*round_multiplier(l)
      end
    end
    standings.store(p, p_data[:score])
  end
  standings.to_a.sort_by { |p| -p[1] }
end

def save_mock_bracket(player)
  @mock_brackets_by_player||= Hash.new
  @mock_brackets_by_player[player.name]= {games: @games_by_label}
end

def round_multiplier(label)
  case label.to_i
    when 1
      32
    when 2..3
      16
    when 4..7
      8
    when 8..15
      4
    when 16..31
      2
    when 32..63
      1
  end
end

def verify_displayed_standings(standings)
  leader_board = page.all('#leader_board tr')
  expect(leader_board).not_to be_empty
  leader_board.each_with_index do |tr, index|
    expect(tr).to have_selector('.player_summary')
    expect(tr).to have_content(standings[index][0])
    expect(tr).to have_content(standings[index][1])
  end
end

def attempt_to_change_a_team_name_as_a_player(new_name, wrong_name)
  node_name = construct_team_css_node_name lookup_label_by_new_name(new_name)
  within(node_name) do
    fill_and_click_script =
        %Q(
         $('#{node_name} #{INPUT_TEAM_CSS}').focus().val('#{wrong_name}');
         $('#{node_name} #{INPUT_TEAM_CSS}').trigger('change');
       )
    page.driver.execute_script(fill_and_click_script)
  end
  expect(page).not_to have_content(wrong_name)
end
