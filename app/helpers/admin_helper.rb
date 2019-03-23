module AdminHelper
  def build_scenarios
    ref = @user.bracket
    ref = ref.clone
    to_choose = ref.games.select {|g| g.winner.nil?}.sort_by {|g| -g.label.to_i}.to_a
    # chose all but last, choose 1, then the other
    puts "SIZE: #{to_choose.length}"
    @scenarios = []
    choose_both_winners ref, to_choose
    @scenarios
  end

  def choose_both_winners(ref, to_choose, i = 0)
    puts "index to start from: #{i}"
    if to_choose.length == i
      result = compute_scores_for_scenario ref
      puts 'have a new result'
      @scenarios << build_scenario(result, to_choose)
    else
      to_choose[i..-1].each do |g|
        ref.lookup_ancestors(g).sort_by {|s| s.label.to_i}.each do |a|
          puts "Choose for #{g.label}: "+to_choose.map {|t| t.winner}.join(', ')
          g.winner = a.winner
          choose_both_winners ref, to_choose, i + 1
          to_choose[i..-1].each do |t|
            t.winner = nil
          end
        end
      end
    end
  end

  def capture_winners(games_to_scrape)
    games_to_scrape.each_with_object({}) do |g, by_round|
      round_key = "Round #{g.round}"
      by_round[round_key] = [] unless by_round[round_key].is_a? Array
      by_round[round_key] << g.winner
    end
  end

  def compute_scores_for_scenario(ref)
    @players.each {|p| p.score ref}
  end

  def build_scenario(result, to_choose)
    s = Scenario.new
    s.scenario_list = capture_winners(to_choose)
    s.result = result
    s
  end
end