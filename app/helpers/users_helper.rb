module UsersHelper

  def update_player_scores
    players= User.where(role: :player)
    if players.length > 1
      reference= Admin.get.bracket
      players.order('current_score desc').sort_by! { |p| p.score reference }
    end
    @players= User.where(role: :player)
  end

end
