module AdminHelper
  def build_scenarios
    ref = @user.bracket
    ref = ref.clone
    to_choose = ref.games.reject {|g| !g.winner.nil?}.sort_by {|g| -g.label.to_i}.to_a
    # chose all but last, choose 1, then the other
    puts "SIZE: #{to_choose.length}"
    @scenarios = []
    choose_both_winners(ref, to_choose, 0)
  end

  def choose_both_winners(ref, to_choose, i)
    to_choose.slice(i, -1).each_with_index do |g, i|
      if to_choose.length == i
        result = compute_scores_for_scenario ref
        @scenarios << {scenario: capture_winners(to_choose), result: result}
      else
        ref.lookup_ancestors(g).sort_by {|got| got.label}.each do |a|
          g.winner = a.winner
          choose_both_winners ref, to_choose, i + 1
        end
      end
    end
  end

  def capture_winners(games_to_scrape)
    games_to_scrape.each_with_objec({}) do |g, by_round|
      round_key = "Round #{g.round}"
      by_round[round_key] = [] unless by_round[round_key].is_a? Array
      by_round[round_key] << g.winner
    end
  end

  def compute_scores_for_scenario(ref)
    @players.each {|p| p.score ref}
  end
end
