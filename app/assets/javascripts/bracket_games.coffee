#= require store_wrapper
#= require channels/game_updater
class BracketGame
  buildOption: (bId, n) ->
    [displayName, value]= @getBracketEntry(bId, n)
    "\n" + '<option value="' + value + '">' + displayName + '</option>'

  buildSelectOptionsFor: (input) ->
    optionString = '<option value>Choose winner...</option>'
    optionString += @buildOption(input.bracket_id, ancestor) for ancestor in StoreWrapper.getAncestors(input.node)
    optionString

  chooseWinner: (target) ->
    @updateOptions(t) for t in $(target)
    return

  getBracketEntry: (bId, n) ->
    e = StoreWrapper.getStoreName(bId, n)
    if e?
      name = e
      e = n
    else # use value stored in 'winner' slot
      e = StoreWrapper.getStoreWinnersLabel(bId, n)
      name = StoreWrapper.getStoreName(bId,  e)
    !name? and name = ''
    !e? and e = ''
    [name, e]

  updateDescendant: (input) ->
    dNode = StoreWrapper.getDescendant input.node
    if dNode?
      input.node = dNode
      descWinLabel = @updateNode(input)
      @updateLocalBracket(input) if input.invalidated == descWinLabel

  updateLocalBracket: (input) ->
    # input.node contains the node being updated, so have to look up descendants
    # to know which to update consequently
    # steps:
    # 1) update input.node in the store
    # if a descendent exists:
    # 2) add input.winners_label to the descendent node
    # if input.node had no prior winner:
    #   done
    # else
    #   3) make descendent red
    #
    @updateServer(input)
    oldWinLabel = StoreWrapper.getStoreWinnersLabel input.bracket_id, input.node
    oldWinLabel = '' unless oldWinLabel?
    StoreWrapper.updateStore input
    input.invalidated = oldWinLabel unless input.invalidated? # propagate only the first change
    input.winner = input.winners_label = '' # not valid to propagate from here.
    @updateDescendant(input)

  updateNode: (input) ->
    $descNode = $('select#game_' + input.node)
    sel = $descNode.find(':selected')
    descWinner = sel.text()
    descWinLabel = sel.val()
    $descNode.empty()
    $descNode.append($.parseHTML(@buildSelectOptionsFor input))
    if input.invalidated != ''
      # @updateServer(input)
      if descWinLabel? and descWinLabel == input.invalidated
        $descNode.addClass('red_winner_state')
      else if descWinLabel != ''
        $descNode.find('option[value="' + descWinLabel + '"]').prop('selected', true)
      else
        $descNode.children().first().value = 'Choose winner...'
        $descNode.children().first().selected = true
    descWinLabel

  updateOptions: (target) ->
    node = $(target).attr 'node'
    bId = $('table.bracket').data 'bracket_id'
    winnerLabel = $(target).find(':selected').val() # an integer, the label of the winning team
    winner = $(target).find(':selected').text()
    $(target).removeClass('red_winner_state')
    input = {node: node, winner: winner, bracket_id: bId, winners_label: winnerLabel}
    console.log("update options before updating server: "+JSON.stringify(input))
    @updateLocalBracket(input)

  updateServer: (input)->
    # move this into the loop? why is the front end doing too many games downstream?
    input.game_id = $('select#game_' + input.node)[0].id.split('_')[1]
    console.log("update server's game: "+JSON.stringify(input))
    gameUpdater = GameUpdaters['game_updater_' + input.game_id]
    gameUpdater.update(input)

$ ->
  bracketGame = new BracketGame()
  $('select.game_winner').on 'change', (e) => bracketGame.chooseWinner e.target
