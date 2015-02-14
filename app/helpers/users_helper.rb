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


end
