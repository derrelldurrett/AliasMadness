class GameUpdaterChannel < ApplicationCable::Channel
  def subscribed
    id = params[:id].split('_')[1]
    @game = Game.find(id)
    stream_for(@game)
  end

  def update_game(data)
    winner = Team.find_by_label data[:winner]
    # check that data[:id] is the same as @game.id?
    #    logger.info("update #{@game.id} with winner: #{winner.nil? ? '' : winner.to_s}")
    @game.update!(winner: winner) if data[:bracket_id] == @game.bracket_id
  end
end