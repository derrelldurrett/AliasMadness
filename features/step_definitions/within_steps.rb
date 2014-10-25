def invite_player(name,email)
  fill_in 'Name', with: name
  fill_in 'Email', with: email
  click_button('Invite Player')
end

def login(email, password)
  link = login_path(email: email)
  visit link
  # save_and_open_page
  fill_in 'Password', with: password
  click_button('Login')
end

def login_as_admin
  admin = Admin.get
  email = admin.email
  password = 'foobaer'
  login(email, password)
end

def login_as_player(player)
  email= player.email
  password= player.remember_for_email
  login(email, password)
  @logged_in_player= player
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
  case
    when /\Alogin\z/i
      login_path(email: @email)
    when /users\/(\d+)/i
      user_path(id: $1)
    else
      raise %Q{Can't find path_to entry for #{pageName}!}
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
  puts 'Choosing '+game[:winner][:new_name]+' in '+ game[:label].to_s
  within(td_node_name) do
    choose_winner_script = %Q(
      $('#{td_node_name} #{GAME_WINNER_CSS}').val('#{game[:winners_label]}');
      $('#{td_node_name} #{GAME_WINNER_CSS}').focus().trigger('change');
      )
    page.driver.execute_script(choose_winner_script)
  end
end

def check_players_games
  bracket= Bracket.find_by_user_id @logged_in_player.id
  players_games= bracket.games.sort_by { |g| g.label }
  players_games.reverse!
  players_games.each do |p|
    puts 'Comparing game '+p.to_s+' to '+game_by_label(p.label).to_s
    expect(p.winner).not_to be_nil
    expect(p.winner.name).to eq(game_by_label(p.label)[:winner][:new_name])
  end
end