class ScenarioFactory
  class << self
    # r is a Bracket, g is a Game, o is a Hash, keys are game labels.
    def build_ancestors(r, g, o)
      r.lookup_ancestors(g).cache_obj(o).sort_by_obj_label
    end

    def build_scenarios
      data = initialize_scenario_data
      return if data.nil?
      choose_both_winners data, sorted_games_with_ancestors(data[:games])
      process_and_store_scenarios
    # rescue => exception
    #   Delayed::Worker.logger.info exception.message
    #   Delayed::Worker.logger.info exception.backtrace.join("\n")
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
          live_teams: build_surviving_teams(p, gs[:games].values.map { |h| h[:game].label })
      }
    end

    def build_players(ref, data)
      @players_with_scores = User.where(role: :player).map { |p| build_player(p, ref, data) }
      build_predicted_teams
      Delayed::Worker.logger.info "Games remaining: #{data[:ancestors].length}"
      Delayed::Worker.logger.info "Teams remaining: #{data[:teams].to_a.join("\t") {|t| t.name}}"
    end

    # Collapse the list of teams that the players have predicted into a Set that we check against
    # The idea is that if none of the teams moving on to the next round are not predicted to do so
    # by any player, there's no need to compute those scenarios.
    # reqts:
    # 1. need to be able to address a single game by label to change its team (so that as we step
    # through the list of games to choose winners for, we have the right list of currently set winners),
    # 2. need to be able to address a round, and get the list of teams that are still alive in this
    # scenario,
    # 3. to do 2 with the least effort possible, we need to be able to ask if moving to the next game
    # should trigger the check that the scenario is done (which means that all of the choices we have made
    # in this scenario for this round are not chosen in the next round by any player).
    def build_predicted_teams
      @predicted_teams = Hash.new {|h,k| h[k] = Set.new}
      @players_with_scores.each do |pwt|
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
      games = p.bracket.games.where(label: gs)
      games.each_with_object(Hash.new {|h,k| h[k] = Set.new}) do |g, o|
        o[g.round] << g.winner unless g.winner.eliminated?
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
    def choose_both_winners(ref_games, have_ancestors, i = 0)
      if scenario_done? have_ancestors, i
        puts "constructing result #{@scenarios.length+1}"
        construct_result have_ancestors
      else
        h_game = have_ancestors[i][1]
        h_game[:ancestors].each do |a|
          w = ref_games[:games][a.label][:game].winner
          g = h_game[:game]
          g.winner = w
          @checker.insert_game_winner g
          choose_both_winners ref_games, have_ancestors, i + 1
          @checker.remove_game_winner g
          g.winner = nil
        end
      end
    end

    def compute_scores_for_scenario(ref)
      @players_with_scores.build_predicted_scores(ref).sort_by_desc_score.build_display_list
    end

    def construct_result(have_ancestors)
      result = compute_scores_for_scenario have_ancestors
      @scenarios << build_scenario(result, have_ancestors)
    end

    def initialize_scenario_data
      ref = Admin.get.bracket.reload
      data = build_data_hash ref
      return if data.nil?
      build_players ref, data
      @scenarios = []
      @checker = Checker.new data[:games]
      data
    end

    def process_and_store_scenarios
      Delayed::Worker.logger.info "Saving #{@scenarios.length} scenarios with #{@scenarios[0].remaining_games} games remaining"
      Scenario.transaction do
        Scenario.all.delete_all
        @scenarios.each { |s| s.save! }
      end
    end

    # We're done if g is the last in its round, and
    def scenario_done?(h, i)
      i != 0 and (h.length == i or disjoint_winners? h, i)
    end

    # this has to be protected from being called if i == 0
    def disjoint_winners?(h, i)
      g = h[i-1][1][:game]
      r = g.round
      g.last_in_round? and not @checker.winners_in_next_round?(r, @predicted_teams)
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
    sort_by { |k, _v| -k.to_i }
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

class Checker

  def initialize(game_data)
    @game_winners_by_round = Hash.new { |h,k| h[k] = Hash.new }
    # from the game with the next larger label in game_data without a winner to the next round boundary
    # add those games' winners to the hash
    largest_label = game_data.select { |_k,v| v[:game].winner.nil? }.sort_by_desc_numeric_key[0][0]
    begin
      g = next_labelled_game largest_label, game_data
      @game_winners_by_round[g.round][g.label] = g.winner
      largest_label = next_label largest_label
    end until g.last_in_round?
  end

  def next_label(l)
    (l.to_i+1).to_s
  end

  def next_labelled_game(l,d)
    d[next_label l][:game]
  end

  def noop; end

  def insert_game_winner(g)
    # Init the set of winners for this
    @game_winners_by_round[g.round][g.label] = g.winner
  end

  def remove_game_winner(g)
    @game_winners_by_round[g.round][g.label] = nil
  end

  def winners_in_next_round?(r, compare_to_by_round)
    not (compare_to_by_round[r+1] & @game_winners_by_round[r].values).empty?
  end
end