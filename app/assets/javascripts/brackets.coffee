# Place all the behaviors and hooks related to the matching controller here.
#= require_self
#= require common
#= require game_update

buildOption = (bId, n) ->
  [displayName, value]= getBracketEntry(bId, n)
  "\n" + '<option value="' + value + '">' + displayName + '</option>'

#
buildSelectOptionsFor = (input) ->
  optionString = '<option value>Choose winner...</option>'
  optionString += buildOption(input.bracket_id, ancestor) for ancestor in StoreWrapper.getAncestors(input.node)
  optionString

chooseWinner = (target) ->
  updateOptions(t) for t in $(target)
  return

fixTeamNames = (e) ->
  e.preventDefault()
  target = e.target
  $.ajax
    type: 'PUT'
    url: '/lock_names'
    beforeSend: (xhr) ->
      xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
    data:
      'fix_team_names': true
    success: (data, textStatus, jqXHR) ->
      Common.reloadPage()
    error: (jqXHR, textStatus, errorThrown) ->
      Common.showError errorThrown, textStatus

getBracketEntry = (bId, n) ->
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

loadBracket = (e) ->
  loadBracketData()
  loadBracketAncestors()

loadBracketAncestors = ->
  ancestors = $('table.bracket').data 'ancestors'
  StoreWrapper.setAncestorData(n, a) for n, a of ancestors

loadBracketData = ->
  data = $('table.bracket').data 'bracket'
  bracketId = data.id
  StoreWrapper.localStore(bracketId, node) for node in data.nodes
  # Using jQuery.one() means we *must* clear the data-bracket attribute before continuing.
  $('table.bracket').data 'bracket', ''
  $('table.bracket').data 'bracket_id', bracketId

lockPlayersBrackets = (e) ->
  e.preventDefault()
  $(e.target).prop('disabled', true)
  $.ajax
    contentType: 'application/json'
    type: 'PUT'
    url: '/lock_players_brackets'
    beforeSend: (xhr) ->
      xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
    data: JSON.stringify({"lock_players_brackets": true})
    success: (data, textStatus, jqXHR) ->
      Common.reloadPage()
    error: (jqXHR, textStatus, errorThrown) ->
      Common.showError errorThrown, textStatus
    complete: (jqXHR, textStatus) ->
      $(e.target).prop('disabled', false)

nameTeam = (target) ->
  sendTeamNameUpdate(t) for t in $(target)

# wLabel is the label of the old winner, and if the node has this winner or no winner, update it
nodeNeedsUpdate = (jqn, wLabel) ->
  jqn[0]['selected'] or
    (jqn[1]['selected'] and jqn[1]['value'] == wLabel) or
    (jqn[2]['selected'] and jqn[2]['value'] == wLabel)

sendTeamNameUpdate = (target) ->
  [teamId,bracketId,node,newName] = teamUpdateSetup target
  $.ajax
    type: 'PUT'
    url: '/teams/' + teamId
    beforeSend: (xhr) ->
      xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
    data:
      'team[name]': newName
      'bracket[id]': bracketId
      'bracket[node]': node
    success: (data, textStatus, jqXHR) ->
      updateLocalBracket node: node, data: data, name: newName, bracket_id: bracketId
      Common.reloadPage()
    error: (jqXHR, textStatus, errorThrown) ->
      Common.showError errorThrown, textStatus
      wipeTextField target

teamUpdateSetup = (t) ->
  newName = t.value
  node = $(t).closest('td').data('node')
  teamId = $(t).next()[0].value
  bracketId = $('table.bracket').data 'bracket_id'
  !bracketId? and bracketId = $('table.bracket').data('bracket').id
  [teamId,bracketId,node,newName]

updateDescendant = (input) ->
  dNode = StoreWrapper.getDescendant input.node
  if dNode?
    $descNode = $('select#game_' + dNode)
    sel = $descNode.find(':selected')
    descWinner = sel.text()
    descWinLabel = sel.val()
    $descNode.empty()
    input.node = dNode
    $descNode.append($.parseHTML(buildSelectOptionsFor input))
    if input.invalidated != ''
      if descWinLabel? and descWinLabel == input.invalidated
        $descNode.addClass('red_winner_state')
      else if descWinLabel != ''
        $descNode.find('option[value="'+descWinLabel+'"]').prop('selected', true)
      else
        $descNode.children().first().value = 'Choose winner...'
        $descNode.children().first().selected = true
    updateLocalBracket(input) if input.invalidated == descWinLabel

updateLocalBracket = (input) ->
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
  oldWinLabel = StoreWrapper.getStoreWinnersLabel input.bracket_id, input.node
  oldWinLabel = '' unless oldWinLabel?
  StoreWrapper.updateStore input
  input.invalidated = oldWinLabel unless input.invalidated? # propagate only the first change
  input.winner = input.winners_label = '' # not valid to propagate from here.
  updateDescendant(input)

updateOptions = (target) ->
  node = $(target).attr 'node'
  bId = $('table.bracket').data 'bracket_id'
  winnerLabel = $(target).find(':selected').val() # an integer, the label of the winning team
  winner = $(target).find(':selected').text()
  $(target).removeClass('red_winner_state')
  console.log('new call to update options')
  updateLocalBracket({node: node, winner: winner, bracket_id: bId, winners_label: winnerLabel})

wipeTextField = (targetNode) ->
  targetNode.value = ''

$ ->
  $('input.team_name').on 'change', (e) => nameTeam e.target
  $('select.game_winner').on 'change', (e) => chooseWinner e.target
  $('button#team_entry_done').on 'click', (e) => fixTeamNames e
  $('button#submit_games').on 'click', (e) => GameUpdate.sendGameUpdates e
  $('button#lock_players_brackets').on 'click', (e) => lockPlayersBrackets e
  $('table.bracket').one 'focusin', (e) => loadBracket e.target

