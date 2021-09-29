# Place all the behaviors and hooks related to the matching controller here.
#= require_self
#= require common
#= require game_update

buildOption = (bId, n) ->
  [displayName, value]= getBracketEntry(bId, n)
  "\n" + '<option value="' + value + '">' + displayName + '</option>'

buildSelectOptionsFor = (bracketId, node) ->
  optionString = '<option value>Choose winner...</option>'
  optionString += buildOption(bracketId, ancestor) for ancestor in StoreWrapper.getAncestors(node)
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

updateLocalBracket = (input) ->
  # input.node contains the node being updated, so have to look up descendants
  # to know which to update consequently
  node = input.node
  bId = input.bracket_id
  oldWinLabel = StoreWrapper.getStoreWinnersLabel bId, node
  StoreWrapper.updateStore input
  newWinLabel = input.winners_label
  if !oldWinLabel? or oldWinLabel != newWinLabel
    dNode = StoreWrapper.getDescendant node
    if oldWinLabel? and newWinLabel != '' and dNode?
      $gameNode = $('select#game_' + dNode)
      sel = $gameNode.find(':selected')
      curWinner = sel.text()
      curWinLabel = sel.val()
      $gameNode.empty()
      $gameNode.append($.parseHTML(buildSelectOptionsFor bId, dNode))
      if oldWinLabel? and oldWinLabel != ''
        if curWinLabel? and curWinLabel == oldWinLabel
          $gameNode.addClass('red_winner_state')
        else
          $gameNode.find('option[value="'+curWinLabel+'"]').prop('selected', true)
      updateLocalBracket({node: dNode, winner: curWinner, bracket_id: bId, winners_label: curWinLabel})

updateOptions = (target) ->
  node = $(target).attr 'node'
  bId = $('table.bracket').data 'bracket_id'
  winnerLabel = $(target).find(':selected').val() # an integer, the label of the winning team
  winner = $(target).find(':selected').text()
  $(target).removeClass('red_winner_state')
  updateLocalBracket({node: node, winner: winner, bracket_id: bId, winners_label: winnerLabel})

# wLabel is the label of the old winner, and if the node has this winner or no winner, update it
nodeNeedsUpdate = (jqn, wLabel) ->
  jqn[0]['selected'] or
    (jqn[1]['selected'] and jqn[1]['value'] == wLabel) or
    (jqn[2]['selected'] and jqn[2]['value'] == wLabel)

wipeTextField = (targetNode) ->
  targetNode.value = ''

$ ->
  $('input.team_name').on 'change', (e) => nameTeam e.target
  $('select.game_winner').on 'change', (e) => chooseWinner e.target
  $('button#team_entry_done').on 'click', (e) => fixTeamNames e
  $('button#submit_games').on 'click', (e) => GameUpdate.sendGameUpdates e
  $('button#lock_players_brackets').on 'click', (e) => lockPlayersBrackets e
  $('table.bracket').one 'focusin', (e) => loadBracket e.target

