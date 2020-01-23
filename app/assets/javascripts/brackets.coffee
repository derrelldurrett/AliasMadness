# Place all the behaviors and hooks related to the matching controller here.
#= require_self
#= require common
#= require game_update

buildGameNode = (bId, d) ->
  $gameNode = $('select#game_' + d)
  $gameNode.empty()
  $gameNode.append($.parseHTML(buildSelectOptionsFor bId, d))

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
  else
    # use value stored in 'winner' slot
    e = StoreWrapper.getStoreWinnersLabel(bId, n)
    name = StoreWrapper.getStoreName(bId,  e)
  !name? and name = ''
  !e? and e = ''
  [name, e]

loadBracket = (e) ->
  loadBracketData()
  loadBracketAncestors()
  return

loadBracketAncestors = ->
  ancestors = $('table.bracket').data 'ancestors'
  StoreWrapper.setAncestorData(n, a) for n, a of ancestors
  return

loadBracketData = ->
# Using jQuery.one() means we *must* clear the data-bracket attribute
# before continuing.
  data = $('table.bracket').data 'bracket'
  bracketId = data.id
  StoreWrapper.localStore(bracketId, node) for node in data.nodes
  $('table.bracket').data 'bracket', ''
  $('table.bracket').data 'bracket_id', bracketId
  return

lockPlayersBrackets = (e) ->
  e.preventDefault()
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
  StoreWrapper.updateStore input
  # input.node contains the node being updated, so have to lookup descendant
  # to know which to update consequently
  n = input.node
  bId = input.bracket_id
  while  d = StoreWrapper.getDescendant n
    buildGameNode(bId, d)
    n = d
  return

updateOptions = (target) ->
  node = $(target).attr 'node'
  winnerLabel = $(target).find(':selected').val() # an integer, the label of the winning team
  bId = $('table.bracket').data 'bracket_id'
  winner = $(target).find(':selected').text() # Store.get(buildLocalStoreLabel(bId,winnerLabel,'name'))
  updateLocalBracket({node: node, winner: winner, bracket_id: bId, winners_label: winnerLabel})
  return

wipeTextField = (targetNode) ->
  targetNode.value = ''

$ ->
  $('input.team_name').on 'change', (e) => nameTeam e.target
  $('select.game_winner').on 'change', (e) => chooseWinner e.target
  $('button#team_entry_done').on 'click', (e) => fixTeamNames e
  $('button#submit_games').on 'click', (e) => GameUpdate.sendGameUpdates e
  $('button#lock_players_brackets').on 'click', (e) => lockPlayersBrackets e
  $('table.bracket').one 'focusin', (e) => loadBracket e.target

