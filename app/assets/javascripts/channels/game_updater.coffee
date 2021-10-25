#= require bracket_games
class @GameUpdater
  constructor: (gameLabel) ->
    @labelAsSelector = 'td.game[data-node="'+gameLabel+'"]'

  channel: ->
    channel: "GameUpdaterChannel"
    game: $(@labelAsSelector).data 'game-update'
    id: $(@labelAsSelector)[0].id

  connected: ->

  disconnected: ->

  gameId: (gameId) ->
    'game_'+gameId

  recieved: (data) ->
    # change the mark-up of the game in the bracket
    # data will need to indicate the label of the game being changed
    # if the data indicates that this is a successful change for this game (same bracket_id?)
    # then we should update the select box (make the first option be the same text as the selected team)
    # and if it's after brackets are locked it should change the class to red_winner_state or green_winner_state
    node = data.node
    # if the node's id is the same as the game_id in data, we're still before brackets locked
    if gameId(data.game) == $('td.game[data-node="'+node+'"]')[0]?.id
      # manipulate the select box a la brackets.coffee's #updateDescendant
      bracketGame = new BracketGame()
      bracketGame.updateNode(data)
    else
      # after brackets locked, if the winner is the same as the winner in the node, it's green, else red
      if data.winner == $('td.game[data-node='+node+']').text().trim()
        $('td.game[data-node='+node+']').removeClass('grey_winner_state').addClass('green_winner_state')
      else
        $('td.game[data-node='+node+']').removeClass('grey_winner_state').addClass('red_winner_state')

  update: (input) ->
    @perform 'update_game', id: input.game_id, winner: input.winners_label, bracket_id: input.bracket_id

  @buildGameUpdater: (gameLabel) ->
    gameUpdater = new GameUpdater(gameLabel)
    GameUpdaters['game_updater_'+gameLabel] = GameUpdaters.cable.subscriptions.create gameUpdater.channel(), gameUpdater

  @buildGameUpdaters: ->
    @buildGameUpdater(gameUpdaterId) for gameUpdaterId in [1..63]
