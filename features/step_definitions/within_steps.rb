def seed_database
  require_relative(%q(../../db/seeds))
  reset_database
  seed_admin
  store_team_data
end

def reset_database
  User.all.each { |e| e.delete }
  Bracket.all.each { |e| e.delete }
  Game.all.each { |e| e.delete }
  Team.all.each { |e| e.delete }
end

WHICH_TIME={first: 0, second: 1}
ADMINS_LABEL_BLOCK=[63.downto(45), 44.downto(26)]


def invite_player(name, email)
  fill_in 'Name', with: name
  fill_in 'Email', with: email
  click_button('Invite Player')
end

def login(email, password)
  link = login_path(email: email)
  visit link
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
  password= $my_fake_password
  @logged_in_player= @user= player
  login(email, password)
end

def logged_in_player
  @logged_in_player
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

def build_game_css(label, winner_state=nil)
  winner_state= (winner_state.nil? ? 'grey' : winner_state) + '_winner_state'
  %Q(td.#{winner_state}.game[data-node="#{label}"])
end


def path_to(page_name)
  case page_name
    when /\Alogin\z/i
      login_path(email: @email)
    when /Edit Bracket/i
      puts 'Visiting '+page_name+' for user '+@user.id.to_s
      user_path(id: @user.id)
    when /Send Message/i
      new_admin_message_path
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

def build_winner_script(game, td_node_name, winner=game[:winners_label])
  %Q(
          $('#{td_node_name} #{GAME_WINNER_CSS}').val('#{winner}');
          $('#{td_node_name} #{GAME_WINNER_CSS}').focus().trigger('change');
          )
end

def enter_game_winner(game)
  td_node_name= build_game_css(game[:label])
  within(td_node_name) do
    choose_winner_script = build_winner_script(game, td_node_name)
    # puts "Script to execute:\n"+choose_winner_script.strip
    page.driver.execute_script(choose_winner_script.strip)
  end
end

def verify_players_games(id)
  bracket= Bracket.find_by_user_id id
  players_games= bracket.games.sort_by { |g| g.label.to_i }
  players_games.reverse_each do |p|
    p.reload
    expect(p.winner).not_to be_nil
    expect(p.winner.name).to eq(game_by_label(p.label)[:winner][:new_name])
  end
end

N_PLAYERS= 5

def team_data_by_label(label)
  @team_data_by_label||= hash_by_label Team.all
  @team_data_by_label[label]
end

def enter_players_bracket_choices_and_save_bracket(player)
  bracket= Bracket.find_by_user_id player.id
  choose_games_for_bracket bracket
  save_mock_bracket player
end

def create_a_player
  player = FactoryGirl.create(:player)
  add_to_players player
  player
end

def create_the_players
  N_PLAYERS.times do
    create_a_player
  end
end

def players_games_entered
  if get_players.nil? or get_players.empty?
    create_the_players
  end
  get_players.each do |player|
    enter_players_bracket_choices_and_save_bracket(player)
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
    g.reload
    mark_losing_team_eliminated g, bracket
  end
end

def mark_losing_team_eliminated(g, b)
  ancestors= b.lookup_ancestors(g)
  ancestors.each do |a|
    a.reload
    a_team= a.is_a?(Team) ? a : a.winner
    unless a_team.label==g.winner.label
      a_team.update_attributes!({eliminated: true})
      break
    end
  end
end

def hash_by_label(labeled_entities)
  ret= Hash.new
  labeled_entities.each do |e|
    e.reload
    ret[e.label]= e
  end
  ret
end

def pick_game_winners_as_admin(labels, reset_game_data=true)
  admin = Admin.get
  choose_games_for_bracket admin.bracket, labels, reset_game_data
  save_mock_bracket admin
  update_players_scores admin.bracket
end

def add_to_players(player)
  @players||= Array.new
  @players<< player
end

def get_players
  @players
end

STANDINGS_PLAYER=0
STANDINGS_SCORE=1
def compute_expected_standings(which_time)
  admin_games= @mock_brackets_by_player['admin']
  standings= Hash.new
  @mock_brackets_by_player.each do |p, p_data|
    next if p== 'admin'
    p_data[:score]= 0
    ADMINS_LABEL_BLOCK[WHICH_TIME[which_time.to_sym]].each do |l|
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
  leader_board_row = page.all('#leader_board tr')
  # save_and_open_page
  expect(leader_board_row).not_to be_empty
  leader_board_row.each_with_index do |tr, index|
    expect(tr).to have_selector('.player_summary')
    expect(tr).to have_content(standings[index][STANDINGS_PLAYER])
    expect(tr).to have_content(standings[index][STANDINGS_SCORE])
  end
end

def attempt_to_change_a_team_name_as_a_player(name, wrong_name)
  node_name = construct_team_css_node_name lookup_label_by_new_name(name)
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

def lock_team_names
  Team.update_all name_locked: :true
end

def lock_players_brackets
  puts 'locking players brackets!'
  User.where({role: :player}).each do |p|
    b= p.bracket
    b.games.update_all(locked: true)
    b.reload
  end
  User.where({role: :player}).update_all(bracket_locked: true)
end

def page_with_label_and_color(label, color)
  ret= ['game', label.to_s, color].join('_')
  ret.concat '.html'
  ENV['RAILS_ROOT']+'/'+ret
end

def check_players_scores
  reference_bracket= Admin.get.bracket
  update_players_scores reference_bracket
  User.where(role: :player).each do |p|
    expect(p.current_score).not_to be_nil
  end
end

def update_players_scores(bracket)
  User.where(role: :player).each { |u| u.bracket.score bracket }
end

def exact_text_match(text)
  /\A#{Regexp.escape(text)}\z/
end

def verify_player_is_green_state(player)
  expect(page).to have_selector('td.bracket_complete', text: player.name)
end

def change_winner(game)
  ancestors= @players_bracket.lookup_ancestors(game)
  ancestors.each do |a|
    a.reload
    a_team= a.is_a?(Team) ? a : a.winner
    if game.winner!=a_team
      td_node_name= build_game_css(game[:label])
      within(td_node_name) do
        choose_winner_script = build_winner_script(game, td_node_name, a_team.label)
        # puts "Script to execute:\n"+choose_winner_script.strip
        page.driver.execute_script(choose_winner_script.strip)
        sleep 10
      end
    end
  end

end

def winner_reset?(label)
  # use within? build the td string....
  db_game= @players_bracket.lookup_game label
  ancestors= @players_bracket.lookup_ancestors(db_game)
  within(build_css_for_game_select(label)) do
    save_and_open_page
    build_css_for_game_select = build_css_for_game_select(label)
    puts 'checking for css '+build_css_for_game_select
    ancestors.each do |g|
      g.reload
      winner= g.is_a?(Team) ? g : g.winner
      unless winner.nil?
        expect(page).to have_selector(%Q(option[value="#{winner.label}"]))
      end
    end
    expect(page).not_to have_selector(%q(option[selected="selected"]))
  end
  pending
end

def build_css_for_game_select(label)
  %Q(#game_#{label})
end
