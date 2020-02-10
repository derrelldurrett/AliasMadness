class ScenarioFactory
  class << self
    # r is a Bracket, g is a Game, o is a Hash, keys game labels.
    def build_ancestors(r, g, o)
      r.lookup_ancestors(g).cache_obj(o).sort_by_obj_label
    end

    def build_scenarios
      ref = Admin.get.bracket.reload
      data = build_data_hash ref
      return if data.nil?
      players_with_scores = build_players ref, data
      @scenarios = [] # We'll store this after reducing it appropriately
      choose_both_winners data, players_with_scores, sorted_games_with_ancestors(data[:games])
      process_and_store_scenarios
    rescue => exception
      Delayed::Worker.logger.info exception.message
      Delayed::Worker.logger.info exception.backtrace
    end
    handle_asynchronously :build_scenarios

    def score_player(pwg, ref)
      ref.reduce_to_winners(pwg[:unfinished_games]).compute_scores
    end

    private

    def build_data_hash(ref)
      games_without_winners = ref.games.sort_by_obj_label.winner_not_set
      return if games_without_winners.length > 31 # too many games means too big a data set
      @remaining_games = games_without_winners.length
      games_without_winners.as_data_hash(ref)
    end

    # a Player (User w/role :player),
    def build_player(p, r, gs)
      {
          player: p,
          score: p.score(r),
          unfinished_games: p.bracket.games.where(label: gs[:ancestors]),
          live_teams: build_surviving_teams(p, gs)
      }
    end

    def build_players(ref, data)
      players_with_scores = User.where(role: :player).map { |p| build_player(p, ref, data) }
      build_predicted_teams players_with_scores
      Delayed::Worker.logger.info "Games remaining: #{data[:ancestors].length}"
      Delayed::Worker.logger.info "Teams remaining: #{data[:teams].to_a.join("\t") {|t| t.name}}"
      players_with_scores
    end

    # Collapse the list of teams that the players have predicted into a Set that we check against
    def build_predicted_teams(pswts)
      @predicted_teams = Hash.new {|h,k| h[k] = Set.new}
      pswts.each do |pwt|
        pwt[:live_teams].each do |k,v|
          v.each {|t| @predicted_teams[k] << t}
        end
      end
    end

    def build_scenario(result, games)
      s = Scenario.new
      s.scenario_teams = JSON.generate capture_winners(games)
      s.result = JSON.generate result
      s.remaining_games = @remaining_games
      s
    end

    def build_surviving_teams(p, gs)
      games = p.bracket.games.where(label: gs[:team_labels])
      games.each_with_object(Hash.new {|h,k| h[k] = Set.new}) do |g, o|
        o[g.round+1] << g.winner unless g.winner.eliminated?
      end
    end

    def capture_winners(games_to_scrape)
      games_to_scrape.each_with_object({}) do |a_game, by_round|
        g = a_game[1][:game]
        next if g.winner.nil?
        round_key = "Round #{g.round}"
        by_round[round_key] ||= []
        by_round[round_key] << g.winner
      end.each_with_object([]) do |h,o|
        o << "#{h[0]}: "+h[1].to_a.join(', '.freeze)
      end
    end

    # choose all but last, choose 1, then the other, then back up, choose the next one,
    # etc.
    def choose_both_winners(ref_games, players_with_games, have_ancestors, i = 0, finish = false)
      if have_ancestors.length == i or finish
        puts "constructing result #{@scenarios.length+1}"
        construct_result have_ancestors, players_with_games
      else
        h_game = have_ancestors[i][1]
        h_game[:ancestors].each do |a|
          w = ref_games[:games][a.label][:game].winner
          scenario_done = !@predicted_teams[h_game[:game].round].include?(w)
          h_game[:game].winner = w
          choose_both_winners ref_games, players_with_games, have_ancestors, i + 1, scenario_done
          h_game[:game].winner = nil
        end
      end
    end

    def compute_scores_for_scenario(ref, ps_w_games)
      ps_w_games.build_predicted_scores(ref).sort_by_desc_score.build_display_list
    end

    def construct_result(have_ancestors, players_with_games)
      result = compute_scores_for_scenario(have_ancestors, players_with_games)
      @scenarios << build_scenario(result, have_ancestors)
    end

    def process_and_store_scenarios
      Delayed::Worker.logger.info "Saving scenarios".freeze
      Scenario.transaction do
        Scenario.all.delete_all
        @scenarios.each { |s| s.save! }
      end
    end

    def sorted_games_with_ancestors(games)
      games.having_key(:ancestors).sort_by_desc_numeric_key
    end
  end
end

# Make a bunch of extensions of Enumerable to make things look prettier
module Enumerable
  def build_display_list
    each_with_object([]) { |h, o| o << "#{h[:player].name} (#{h[:pred_score]})" }
  end

  def as_data_hash(ref)
    data = {}
    data[:games] = each_with_object({}) do |g, out|
      out[g.label] = { game: g, ancestors: ScenarioFactory.build_ancestors(ref, g, out) }
    end
    data[:ancestors] = data[:games].having_key(:ancestors).map { |h| h[0] }
    data[:team_labels] = data[:games].having_key(:team).map { |h| h[0] }
    data[:teams] = Set.new(data[:games].having_key(:team).map { |h| game_or_team(h[1][:game])[:team] })
    data
  end

  def build_predicted_scores(ref)
    each do |pwg|
      pwg[:pred_score] = pwg[:score]
      pwg[:pred_score] += ScenarioFactory.score_player(pwg, ref)
    end
  end

  def compute_scores
    # TODO: Eventually the computation has to come from the Score module
    sum { |_l, h_ref| h_ref[:game].winner.seed * h_ref[:game].round_multiplier }
  end

  def game_or_team(a)
    a.is_a?(Game) ? { game: a, team: a.winner } : {team: a}
  end

  # Call on a hash
  def having_key(k)
    select { |_k,v| v.key? k }
  end

  # keep track of what label matches what game or team
  def cache_obj(o)
    each { |a| o[a.label] = game_or_team(a) unless o.key?(a.label) }
  end

  # Call on a Hash with keys that are strings of integers, or integers
  def sort_by_desc_numeric_key
    sort_by { |k| -k[0].to_i }
  end

  def sort_by_desc_score
    # We don't need more than 10 in the list
    sort_by { |pwg| -pwg[:pred_score] }[0..10]
  end

  def sort_by_obj_label
    sort_by { |a| -a.label.to_i }
  end

  # Given an unfinished games list(ActiveRecord::Collection) produce only those
  # members of self that have a winner that matches that of the unfinished games
  def reduce_to_winners(unfinished_games)
    filter do |label, h_ref|
      h_ref[:game].winner == unfinished_games.where(label: label).first.winner
    end
  end

  # Use this to select only the games where there's not a winner assigned
  def winner_not_set
    select { |g| g.winner.nil? }
  end
end