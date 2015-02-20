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
      unless games_nil
        complete_class=' bracket_complete'
      end
    end
    complete_class
  end
end
