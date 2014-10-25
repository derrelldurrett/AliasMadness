module BuildGameData

  def game_data # not sure if this is necessary
    init_game_data if @games.nil?
    @games
  end

  def game_by_label(label)
    init_game_data if @games_by_label.nil?
    @games_by_label[label.to_i]
  end

  # Currently broken and unused...
  # def game_by_participants(team1,team2)
  #   init_game_data if @games_by_participants.nil?
  #   if @games_by_participants.has_key? team1+'_'+team2
  #     game= @games_by_participants[team1+'_'+team2]
  #   elsif @games_by_participants.has_key? team2+'_'+team1
  #     game= @games_by_participants[team2+'_'+team1]
  #   else
  #     raise BadProgrammerError 'No game found for pair '+team1+' and '+team2
  #   end
  #   game
  # end

  def game_descendant(label)
    @games_by_label[@game_descendant_label_by_label[label]]
  end

  def get_descendant_label(label)
    game_descendant(label)[:label]
  end

  private

  def init_game_data
    srand 5
    build_games
    build_game_lookups
  end

  def build_game_lookups
    @games_by_label= Array.new
    # @games_by_participants= Hash.new
    @games.each do |g|
      @games_by_label[g[:label].to_i]= g
      # maybe just should set this to the game, full-stop?
      # @games_by_participants[g[:participants]]= g
    end
  end

  def build_games
    @games= Array.new
    @game_descendant_label_by_label= Hash.new
    # consume two teams, make a game and choose a winner, and get the next two teams
    loop do
      teams= consume_two_teams
      winner= choose_winner teams
      @games << {label: @game_label,
                 winner: winner,
                 winners_label: winner[:label],
                 participants: teams
      }
      puts 'Game '+@game_label.to_s+ ' Teams: '+teams.to_s
      break if @game_label == 1
      @game_label= @game_label-1
    end
  end

  def consume_two_teams
    init_loop if @t_ptr.nil?
    teams= Array.new
    [0,1].each do |i|
      if @t_ptr >= @teams.length
        g = @games[@g_ptr]
        @teams<< g[:winner]
        @game_descendant_label_by_label[g[:label].to_s]= @game_label
        @g_ptr= @g_ptr+1
      end
      teams<< get_team
      @t_ptr= @t_ptr+1
    end
    teams
  end

  def init_loop
    @t_ptr= 0
    @g_ptr= 0
    @teams= team_data
    @game_label= @teams.length-1
  end

  def get_team
    if @t_ptr < @teams.length
      @teams[@t_ptr]
    else
      @games[@t_ptr-@teams.length]
    end
  end

  def choose_winner(teams)
    teams[rand(2)] # rand(2) produces either 0 or 1.
  end
end

World(BuildGameData)