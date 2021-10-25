#= require_self
#= require store_wrapper
#= require channels/game_updater
class @BracketGame
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
      @updateLocalBracket(input) if (input.invalidated == descWinLabel and input.invalidated != '')

  # Called to update a node, both recursively as warranted, and if an ancestor has changed. Since this includes if a
  # team name has changed, we need to be sure to guard against that.
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
    gameUpdater = GameUpdaters['game_updater_' + input.node]
    gameUpdater?.update(input) # guard against no updater for the Team name nodes.
    StoreWrapper.updateStore input
    oldWinLabel = StoreWrapper.getStoreWinnersLabel input.bracket_id, input.node
    oldWinLabel = '' unless oldWinLabel?
    input.invalidated = oldWinLabel unless input.invalidated? # propagate only the first change
    input.winner = input.winners_label = '' # not valid to propagate from here.
    @updateDescendant(input)

  updateNode: (input) ->
    $node = $('select#game_' + input.node)
    sel = $node.find(':selected')
    winLabel = sel.val()
    $node.empty()
    $node.append($.parseHTML(@buildSelectOptionsFor input))
    if input.invalidated != ''
      if winLabel? and winLabel == input.invalidated
        $node.addClass('red_winner_state')
      else if winLabel != ''
        $node.find('option[value="' + winLabel + '"]').prop('selected', true)
      else
        $node.children().first().value = 'Choose winner...'
        $node.children().first().selected = true
    else if winLabel != ''
      $node.find('option[value="' + winLabel + '"]').prop('selected', true)
    winLabel

  updateOptions: (target) ->
    node = $(target).attr 'node'
    bId = $('table.bracket').data 'bracket_id'
    winnerLabel = $(target).find(':selected').val() # an integer, the label of the winning team
    winner = $(target).find(':selected').text()
    $(target).removeClass('red_winner_state')
    input = {node: node, winner: winner, bracket_id: bId, winners_label: winnerLabel}
    @updateLocalBracket(input)

$ ->
  bracketGame = new BracketGame()
  $('select.game_winner').on 'change', (e) => bracketGame.chooseWinner e.target
