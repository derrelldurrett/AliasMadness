# frozen_string_literal: true

def seed_database
  require_relative('../../db/seeds')
  reset_database
  seed_admin
  store_team_data
end

def reset_database
  User.all.each(&:delete)
  Bracket.all.each(&:delete)
  Game.all.each(&:delete)
  Team.all.each(&:delete)
end

WHICH_TIME = { first: 0, second: 1, third: 2 }.freeze
ADMINS_LABEL_BLOCK = [63.downto(45), 63.downto(26), 63.downto(8)].freeze

def invite_player(name, email)
  fill_in 'Name', with: name
  fill_in 'Email', with: email
  click_button('Invite Player')
end

def login(email, password)
  link = login_path(email: email)
  visit link
  if page.has_button? 'Login'
    fill_in 'Password', with: password
    click_button('Login')
  else
    expect(page).to have_text('Final Four')
  end
end

def login_as_admin
  admin = Admin.get.reload
  @user = admin
  login(admin.email, ENV['ALIASMADNESS_PASSWORD'])
end

def login_as_player(player)
  @logged_in_player = @user = player
  login(player.email, $my_fake_password)
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
  ret = {}
  Team.all.each do |t|
    ret[t.name] = t.id
  end
  ret
end

def look_up_team_id_by_original_data(data)
  @look_up_team_id_by_original_data[data]
end

def construct_team_css_node_name(label)
  %(td.team[data-node="#{label}"])
end

def build_game_css(label, winner_state = nil)
  winner_state = (winner_state.nil? ? 'grey' : winner_state) + '_winner_state'
  %(td.#{winner_state}.game[data-node="#{label}"])
end

def path_to(page_name)
  case page_name
  when /\Alogin\z/i
    login_path(email: @email)
  when /Edit Bracket/i
    puts "Visiting #{page_name} for user #{@user.id} (#{@user.name})"
    user_path(id: @user.id)
  when /Send Message/i
    new_admin_message_path
  else
    raise %(Can't find path_to entry for #{page_name}!)
  end
end

def change_a_team_name_as_admin(old_name, new_name)
  node_name = construct_team_css_node_name lookup_label_by_old_name(old_name)
  within(node_name) do
    fill_and_click_script =
      %(
         $('#{node_name} #{INPUT_TEAM_CSS}').focus().val('#{new_name}');
         $('#{node_name} #{INPUT_TEAM_CSS}').trigger('change');
       )
    page.driver.execute_script(fill_and_click_script)
  end
end

def enter_team_names_as_admin
  team_data.each do |t|
    change_a_team_name_as_admin t[:old_name], t[:new_name]
  end
  sleep 2
end

GAME_WINNER_CSS = 'select.game_winner'.freeze
GAME_WINNER_CLASS_CSS = '.game_winner'.freeze

def build_winner_script(game, td_node_name, winner = game[:winners_label])
  %(
      $('#{td_node_name} #{GAME_WINNER_CSS}').val('#{winner}');
      $('#{td_node_name} #{GAME_WINNER_CSS}').focus().trigger('change');
    )
end

def enter_game_winner(game)
  td_node_name = build_game_css(game[:label])
  within(td_node_name) do
    expect(page).not_to have_selector(GAME_WINNER_CSS + '[disabled]')
    choose_winner_script = build_winner_script(game, td_node_name)
    puts "Script to execute:\n" + choose_winner_script.strip
    page.driver.execute_script(choose_winner_script.strip)
  end
end

def verify_players_games(id)
  bracket = Bracket.where(user_id: id).first
  players_games = bracket.games.sort_by { |g| g.label.to_i }
  players_games.to_a.sample(16).reverse_each do |p|
    p.reload
    w = p.winner
    if game_by_label(p.label)[:winner][:new_name].nil?
      expect(w).to be_nil
    else
      expect(w).not_to be_nil
      expect(w.name).to eq(game_by_label(p.label)[:winner][:new_name])
    end
  end
end

N_PLAYERS = 5

def team_data_by_label(label)
  @team_data_by_label ||= hash_by_label Team.all
  @team_data_by_label[label]
end

def complete_brackets(player)
  choose_games_for_bracket player
  save_mock_bracket player
end

def create_a_player
  player = FactoryBot.create(:player)
  player
end

def create_the_players
  N_PLAYERS.times { create_a_player }
end

def players_games_entered
  create_the_players if get_players.nil? || get_players.empty?
  get_players.each do |player|
    complete_brackets(player)
    verify_players_games player.id
  end
end

def games_by_label(bracket)
  @bracket_in_db ||= {}
  @bracket_in_db[bracket.reload.id] ||= {}
  @bracket_in_db[bracket.id][:games_by_label] ||= hash_by_label Game.where(bracket_id: bracket.id)
end

def choose_games_for_bracket(user, labels = 63.downto(1), reset_game_data = true)
  bracket = user.bracket
  reinit_game_data if reset_game_data
  bracket_games_by_label = games_by_label(bracket)
  labels.each do |label|
    g = bracket_games_by_label[label.to_s]
    g.reload
    winning_team = team_data_by_label(game_by_label(label)[:winners_label])
    # puts "assigning winners for #{bracket.id} (#{user.name}) -- node #{label} -- winner #{winning_team.name}"
    g.update!({ winner: winning_team })
    mark_losing_team_eliminated g, bracket if user.admin?
  end
end

def mark_losing_team_eliminated(g, b)
  ancestors = b.reload.lookup_ancestors(g)
  ancestors.each do |a|
    a.reload
    a_team = a.is_a?(Team) ? a : a.winner
    puts "game: #{g.label}, ancestor: #{a.label}; a_team: #{a_team}" if a_team.nil?
    unless a_team.label == g.winner.label
      a_team.update!({ eliminated: true })
      break
    end
  end
end

def hash_by_label(labeled_entities)
  ret = {}
  labeled_entities.each do |e|
    e.reload
    ret[e.label] = e
  end
  ret
end

def pick_game_winners_as_admin(labels, reset_game_data = true)
  admin = User.find_by_role(:admin).reload
  choose_games_for_bracket admin, labels, reset_game_data
  save_mock_bracket admin
  update_players_scores admin.bracket
end

def add_to_players(player)
  @players ||= []
  @players << player
end

def get_players
  User.where(role: :player)
end

STANDINGS_PLAYER = 0
STANDINGS_SCORE = 1

def compute_expected_standings(which_time)
  admin_games = @mock_brackets_by_player['admin']
  standings = {}
  @mock_brackets_by_player.each do |p, p_data|
    next if p == 'admin'

    p_data[:score] ||= 0
    puts "compute score for #{p}"
    ADMINS_LABEL_BLOCK[WHICH_TIME[which_time.to_sym]].each do |l|
      if p_data[:games][l][:winners_label] == admin_games[:games][l][:winners_label]
        p_data[:score] += admin_games[:games][l][:winner][:seed].to_i * round_multiplier(l)
        puts "#{p}: #{p_data[:score]} with seed #{admin_games[:games][l][:winner][:seed]} at label #{l} (with multiplier: #{round_multiplier(l)})}"
      else
        puts "no score at label #{l}"
      end
    end
    standings.store(p, p_data[:score])
    puts "#{p}: #{p_data[:score]}"
  end
  standings.to_a.sort_by { |p| -p[1] }
end

def save_mock_bracket(player)
  @mock_brackets_by_player ||= {}
  @mock_brackets_by_player[player.name] = { games: @games_by_label }
end

def round_multiplier(label)
  case label.to_i
  when 1
    64
  when 2..3
    32
  when 4..7
    16
  when 8..15
    8
  when 16..31
    4
  when 32..63
    2
  end
end

def verify_displayed_standings(standings)
  leader_board_row = page.all('#leader_board tr')
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
      %(
         $('#{node_name} #{INPUT_TEAM_CSS}').focus().val('#{wrong_name}');
         $('#{node_name} #{INPUT_TEAM_CSS}').trigger('change');
       )
    page.driver.execute_script(fill_and_click_script)
  end
  expect(page).not_to have_content(wrong_name)
end

def lock_team_names
  Team.update_all name_locked: true
end

def lock_players_brackets
  puts 'locking players brackets!'
  User.where({ role: :player, bracket_locked: false }).each do |p|
    b = p.bracket
    b.games.update_all(locked: true)
    b.reload
  end
  User.where({ role: :player }).update_all(bracket_locked: true)
end

def page_with_label_and_color(label, color)
  ret = ['game', label.to_s, color].join('_')
  ret << '.html'
  ENV['RAILS_ROOT'] + '/' + ret
end

def check_players_scores
  reference_bracket = Admin.get.bracket.reload
  update_players_scores reference_bracket
  User.where(role: :player).each do |p|
    expect(p.current_score).not_to be_nil
  end
end

def call_update_in_browser
  visit path_to('Edit Bracket')
  click_button 'Update Bracket'
  sleep 10
end

def update_players_scores(bracket)
  User.where(role: :player).each { |u| u.score bracket }
end

def exact_text_match(text)
  /\A#{Regexp.escape(text)}\z/
end

def verify_player_is_green_state(player)
  expect(page).to have_selector('td.bracket_complete', text: player.name)
end

def change_winner(game)
  ancestors = @players_bracket.lookup_ancestors(game)
  ancestors.each do |a|
    a.reload
    a_team = a.is_a?(Team) ? a : a.winner
    next unless game.winner != a_team

    td_node_name = build_game_css(game[:label])
    within(td_node_name) do
      choose_winner_script = build_winner_script(game, td_node_name, a_team.label)
      # puts "Script to execute:\n"+choose_winner_script.strip
      page.driver.execute_script(choose_winner_script.strip)
      sleep 10
    end
  end
end

def winner_reset?(label)
  # use within? build the td string....
  within(build_css_for_game_select(label)) do
    expect(page).not_to have_selector('option[selected="selected"]')
  end
end

def build_css_for_game_select(label)
  %(#game_#{label})
end

def choose_another_player
  exclude = logged_in_player.id
  User.where(role: :player).where.not(id: exclude).first
end

def check_color_matches_team_name(expected_css, is_eliminated, p_game, r_game, winner_state)
  if winner_state == 'green'
    expect(find(expected_css)).to have_text(exact_text_match(p_game.winner.name))
  else
    is_eliminated[p_game.winner.name] = p_game.label
    expect(find(expected_css)).not_to have_text(exact_text_match(r_game.winner.name))
  end
end

def check_winner_state_conditions(is_eliminated, label, p_game, r_game)
  winner_state = p_game.winner == r_game.winner ? 'green' : 'red'
  expected_css = build_game_css(label, winner_state)
  expect page.has_css?(expected_css)
  check_color_matches_team_name(expected_css, is_eliminated, p_game, r_game, winner_state)
end

def check_winners_correctly_listed(is_eliminated, nth, players_bracket, reference_bracket)
  ADMINS_LABEL_BLOCK[WHICH_TIME[nth.to_sym]].each do |l|
    label = l.to_s
    r_game = reference_bracket[label]
    p_game = players_bracket[label]
    [r_game, p_game].each(&:reload)
    expect(r_game.winner).not_to be_nil
    check_winner_state_conditions(is_eliminated, label, p_game, r_game)
  end
end

def check_losers_shown_in_red(is_eliminated, players_bracket)
  is_eliminated.each do |e_name, last_label|
    last_label.to_i.downto(1).each do |l|
      p_game = players_bracket[l.to_s]
      if p_game.winner.name == e_name
        expected_css = build_game_css(l, 'red')
        expect page.has_css?(expected_css)
      end
    end
  end
end

module Enumerable
  # monkey patch Enumerable
  def each_other_id(reject_this)
    ids = each_with_object([]) do |p, o|
      o << p.id
    end
    ids.reject do |p|
      p == reject_this
    end
  end
end
