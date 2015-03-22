module UsersHelper

  def update_player_scores
    players= get_players
    if players.length >= 1
      reference= Admin.get.bracket
      players.sort_by! do |p|
        p.bracket.score reference
        p.reload
      end
    end
    @players= players
  end

  def get_players
    User.where(role: :player)
  end

  def bracket_complete_class(player, is_for_admin)
    complete_class= ''
    if is_for_admin
      games_nil=player.bracket.games.any? { |g| g.winner.nil? }
      complete_class=' bracket_complete' unless games_nil or !players_brackets_locked?
    end
    complete_class
  end


  def clickable(user)
    User.where({id: user.id}).where(bracket_locked: true) ? 'clickable' : ''
  end

  def players_brackets_locked?
    User.where({role: :player}).where(bracket_locked: false).length > 0
  end
end
