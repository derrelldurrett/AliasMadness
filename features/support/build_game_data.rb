module BuildGameData

  srand 9973 # need to be able to get multiple passes through the game data with one
  # random number seed, otherwise all brackets would be the same.

  def game_data # not sure if this is necessary
    init_game_data if @games.nil?
    @games
  end

  def game_by_label(label)
    init_game_data if @games_by_label.nil?
    @games_by_label[label.to_i]
  end

  def game_descendant(label)
    init_game_data if @games_by_label.nil? or @game_descendant_label_by_label.nil?
    @games_by_label[@game_descendant_label_by_label[label.to_s]]
  end

  def get_descendant_label(label)
    @game_descendant_label_by_label[label.to_s]
  end

  def reinit_game_data
    @games = nil
    @games_by_label = nil
    @game_descendant_label_by_label = nil
    @t_ptr = nil
    @g_ptr = nil
  end

  private

  def init_game_data
    build_games
    build_game_lookups
  end

  def build_game_lookups
    @games_by_label = Array.new
    @games.each do |g|
      @games_by_label[g[:label].to_i] = g
    end
  end

  def build_games
    @games = Array.new
    @game_descendant_label_by_label = Hash.new
    # consume two teams, make a game, choose a winner, and get the next two teams
    loop do
      teams = consume_two_teams
      winner = choose_winner teams
      @games << {label: @game_label,
                 winner: winner,
                 winners_label: winner[:label],
                 participants: teams
      }
      break if @game_label == 1
      @game_label = @game_label - 1
    end
  end

  def consume_two_teams
    init_loop if @t_ptr.nil?
    teams = Array.new
    2.times do |i|
      if @t_ptr >= @teams.length
        g = @games[@g_ptr]
        @teams << g[:winner]
        @game_descendant_label_by_label[g[:label].to_s] = @game_label
        @g_ptr = @g_ptr + 1
      end
      teams << get_team
      @t_ptr = @t_ptr + 1
    end
    teams
  end

  def init_loop
    @t_ptr = 0
    @g_ptr = 0
    init_team_data
    @teams = team_data
    @game_label = @teams.length - 1
  end

  def get_team
    if @t_ptr < @teams.length
      @teams[@t_ptr]
    else
      @games[@t_ptr - @teams.length]
    end
  end

  def choose_winner(teams)
    teams[rand(2)] # rand(2) produces either 0 or 1.
  end
end

World(BuildGameData)