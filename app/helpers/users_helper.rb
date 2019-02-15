module UsersHelper
  def update_player_scores
    @players = []
    @players = players = get_players
    if players.length >= 1
      reference = Admin.get.bracket
      @players = players.sort_by do |p|
        p.score reference
        p.reload
      end
    end
  end

  def get_players
    User.where(role: :player)
  end

  def bracket_complete_class(player, is_for_admin)
    complete_class = ''
    if is_for_admin
      games_nil = player.bracket.games.any? {|g| g.winner.nil?}
      complete_class = ' bracket_complete' unless games_nil and !players_brackets_locked?
    end
    complete_class
  end

  def clickable(user)
    User.where({id: user.id}).where(bracket_locked: true) ? 'clickable' : ''
  end

  def create_player(params)
    params[:user][:role] = 'player'
    @user = User.create!(params[:user])
    UserMailer.welcome_email(@user).deliver unless @user.admin?
    @user
  end
end