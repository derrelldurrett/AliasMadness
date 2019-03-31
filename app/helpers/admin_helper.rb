module AdminHelper
  include UsersHelper
  def build_scenarios
    ref = @user.bracket
    games = {}
    ref.games.sort_by_obj_label.winner_not_set.build_game_hash(games, ref)
    players_with_scores = @players.map { |p| build_player(p,ref,games.keys) }
    puts "Games remaining: #{games.length}"
    @scenarios = []
    choose_both_winners games, players_with_scores
    @scenarios
  end

  # a Player (User w/role :player),
  def build_player(p, r, ls)
    {
        player: p,
        score: p.score(r),
        unfinished_games: p.bracket.games.where(label: ls)
    }
  end

  # chose all but last, choose 1, then the other, then back up, choose the next one,
  # etc.
  def choose_both_winners(ref_games, players_with_games, i = 0)
    have_ancestors = ref_games.having_ancestors.sort_by_desc_numeric_key
    if have_ancestors.length == i
      puts 'constructing result'
      construct_result have_ancestors, players_with_games
    else
      j, h_game = have_ancestors[i]
      h_game[:ancestors].each do |a|
        h_game[:game].winner = ref_games[a.label][:game].winner
        choose_both_winners ref_games, players_with_games, i + 1
        h_game[:game].winner = nil
      end
    end
  end

  def construct_result(have_ancestors, players_with_games)
    result = compute_scores_for_scenario have_ancestors, players_with_games
    @scenarios << build_scenario(result, have_ancestors)
  end

  def build_scenario(result, games)
    s = Scenario.new
    s.scenario_list = capture_winners(games)
    s.result = result
    s
  end

  def capture_winners(games_to_scrape)
    games_to_scrape.each_with_object({}) do |a_game, by_round|
      g = a_game[1][:game]
      round_key = "Round #{g.round}"
      by_round[round_key] = [] unless by_round[round_key].is_a? Array
      by_round[round_key] << g.winner
    end.each_with_object({}) do |h,o|
      o[h[0].to_sym] = "#{h[0]}: "+h[1].join(', ')
    end
  end

  def compute_scores_for_scenario(ref, ps_w_games)
    ps_w_games.build_predicted_scores(ref).sort_by_desc_score.build_display_list
  end

  def self.score_player(pwg, ref)
    ref.reduce_to_winners(pwg).compute_scores
  end

  # r is a Bracket, g is a Game, o is a Hash, keys game labels.
  def self.build_ancestors(r,g,o)
    r.lookup_ancestors(g).save_o(o).sort_by_obj_label
  end

  def noop; end
end

module Enumerable
  def build_display_list
    each_with_object([]) { |h, o| o << "#{h[:player].name} (#{h[:pred_score]})" }
  end

  def build_game_hash(_games, ref)
    each_with_object(_games) do |g, o|
      o[g.label] = { game: g, ancestors: AdminHelper.build_ancestors(ref,g,o) }
    end
  end

  def build_predicted_scores(ref)
    each { |pwg| pwg[:pred_score] = pwg[:score] + AdminHelper.score_player(pwg,ref) }
  end

  def compute_scores
    # TODO: Eventually the computation has to come from the Score module
   sum { |_l, h_ref| h_ref[:game].winner.seed * h_ref[:game].round_multiplier }
  end

  # Call on a hash
  def having_ancestors
    select { |_k,v| v.key? :ancestors }
  end

  def save_o(o)
    each { |a| o[a.label] = { game: a } unless o.key?(a.label) }
  end

  # Call on a Hash with keys that are strings of integers, or integers
  def sort_by_desc_numeric_key
    sort_by { |k| -k[0].to_i }
  end

  def sort_by_desc_score
    sort_by { |pwg| -pwg[:pred_score] }[0..10]
  end

  def sort_by_obj_label
    sort_by { |a| -a.label.to_i }
  end

  def reduce_to_winners(pwg)
    filter do |label, h_ref|
      h_ref[:game].winner == pwg[:unfinished_games].where(label: label).first.winner
    end
  end

  def winner_not_set
    select { |g| g.winner.nil? }
  end
end