module Score
  def score(reference_bracket)
    ### once we figure out how to cache this, we'll do that.
    # score= current_score || 0
    # if score==0 or self.updated_at < reference_bracket.newest_game_date
    ###
    score= @current_score= compute_score(reference_bracket)
    self.update_attributes!({current_score: score})
    # end
    score
  end

  private

  def compute_score(reference_bracket)
    my_score=0
    reference_bracket.games_by_label.zip(self.games_by_label) do |g_arr|
      next if g_arr[0].winner.nil?
      my_score += g_arr[0].winner.seed*g_arr[0].round_multiplier if g_arr[0].winner==g_arr[1].winner
    end
#    logger.info %Q(Score for user_id #{self.user_id} (bracket_id-- #{self.id}): #{my_score})
    my_score
  end

end
