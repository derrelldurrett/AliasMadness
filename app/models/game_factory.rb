# frozen_string_literal: true

require 'singleton'
class GameFactory
  include Singleton

  def find_or_create_game(label:, locked: false, winner: nil, bracket: nil)
    @games ||= {}
    if @games.has_key?(label)
      @games[label]
    else
      @games[label] = build_game(label: label, locked: locked, winner: winner, bracket: bracket)
    end
  end

  private def generate_id(label, bracket)
    id = label.to_i
    unless bracket.nil?
      id += (bracket-1)*128
    end
    id
  end

  private def build_game(label:, locked:, winner:, bracket:)
    game = Game.new
    game.id = generate_id(label, bracket)
    game.label = label
    game.locked = locked
    game.winner = winner
    game.winners_label = winner.label unless winner.nil?
    game
  end
end
