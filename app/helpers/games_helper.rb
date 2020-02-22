module GamesHelper
  def game_or_team_options_for_select(bracket, game)
    # produce a list of lists: [[object,display_value],...]
    result = []
    games_or_teams = bracket.lookup_ancestors(game).sort_by {|got| got.label}
    games_or_teams.each do |got|
      result << if got.is_a? Game
                  got.winner.nil? ? ['', nil] :
                      [got.winner.name, got.winner.label]
                else
                  got.nil? ? ['', nil] : [got.name, got.label]
                end
    end
    selected = game.winner.nil? ? nil : game.winner.label
    options_for_select result, selected
  end

  GAME_DISPLAY_CLASS = 'game_display'

  def build_game_class(game, node, bracket_locked)
    [GAME_DISPLAY_CLASS, left_or_right_node(node), color_winner(game.winner, node, bracket_locked)] * ' '.freeze
  end

  GAME_CHOICE_DEFAULT = 'Choose winner...'

  def choose_winner_or(game)
    game.winner.nil? ? GAME_CHOICE_DEFAULT : game.winner.name
  end

  def color_winner(winner, node, bracket_locked)
    # need a space in front
    ' '.freeze + [winner_state(bracket_locked, node, winner), 'winner_state'.freeze].join('_'.freeze)
  end

  private

  def winner_state(bracket_locked, node, winner)
    color = 'grey'.freeze
    if bracket_locked
      w = User.find_by_role(:admin).bracket.lookup_game(node).winner
      w.reload unless w.nil?
      # color is green if the winner is the actual winner
      # color is red if the winner is eliminated
      # color otherwise remains grey if the game is not complete (w.nil?)
      color = if winner == w
                'green'.freeze
              elsif winner.eliminated?
                'red'.freeze
              else
                'grey'.freeze
              end
    end
    color
  end
end
