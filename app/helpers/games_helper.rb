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
    GAME_DISPLAY_CLASS + left_or_right_node(node) + color_winner(game, node, bracket_locked)
  end

  GAME_CHOICE_DEFAULT = 'Choose winner...'

  def choose_winner_or(game)
    game.winner.nil? ? GAME_CHOICE_DEFAULT : game.winner.name
  end

  def color_winner(game, node, bracket_locked)
    color = 'grey'
    if bracket_locked
      w = Admin.get.bracket.lookup_game(node).winner
      unless w.nil?
        # color is red if the game is complete and its winner is eliminated
        color = game.winner == w ? 'green' : 'red'
      end
    end
    ' ' + [color, 'winner_state'].join('_') # need a space in front
  end
end
