module GamesHelper
  def game_or_team_options_for_select(bracket,game)
    # produce a list of lists: [[object,display_value],...]
    result = []
    games_or_teams = bracket.lookup_ancestors(game).sort_by { |got| got.label }
    games_or_teams.each do |got|
      result << if got.is_a? Game
                  got.winner.nil? ? ['',nil] :
                      [got.winner.name, got.winner.label]
                else
                  got.nil? ? ['',nil] : [got.name,got.label]
                end
    end
    options_for_select result
  end
end
