# Place all the behaviors and hooks related to the matching controller here.
#= require_self
#= require store-master/store
attrExists = (bId, g, attr) ->
  Store.get(buildLocalStoreLabel(bId, g, attr))?

buildGameData = (bId) ->
  (gameDataCached for g in [63..1] when (gameDataCached = gameData(g, bId))?)

buildGameNode = (bId, d) ->
  $gameNode = $('select#game_' + d)
  $gameNode.empty()
  $gameNode.append($.parseHTML(buildSelectOptionsFor bId, d))

buildLocalStoreLabel = (bid, node, attr) ->
  "#{bid}_#{node}_#{attr}"

buildLocalStorePairs = (i, n) ->
  localStorePairs = for name, val of n when name isnt 'label'
    [buildLocalStoreLabel(i, n.label, name), val]
  localStorePairs

buildOption = (bId, n) ->
  [displayName, value]= getBracketEntry(bId, n)
  "\n" + '<option value="' + value + '">' + displayName + '</option>'

buildSelectOptionsFor = (bracketId, node) ->
  optionString = '<option value>Choose winner...</option>'
  optionString += buildOption(bracketId, ancestor) for ancestor in getAncestors(node)
  optionString

chooseWinner = (target) ->
  updateOptions(t) for t in $(target)
  return

clearNewGameChoiceFlags = (bId) ->
  expireAttr(bId, g, 'is_new') for g in [63..1] when attrExists(bId, g, 'is_new')

expireAttr = (bId, g, attr) ->
  Store.expire(buildLocalStoreLabel(bId, g, attr))

fixTeamNames = (e) ->
  e.preventDefault();
  target = e.target
  $.ajax
    type: 'PUT'
    url: '/lock_names'
    beforeSend: (xhr) ->
      xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
    data:
      'fix_team_names': true
    success: (data, textStatus, jqXHR) ->
      reloadPage()
    error: (jqXHR, textStatus, errorThrown) ->
      showError errorThrown, textStatus

gameData = (g, bId) ->
  if attrExists(bId, g, 'is_new')
    w = Store.get buildLocalStoreLabel(bId, g, 'winner')
    l = Store.get buildLocalStoreLabel(bId, g, 'winners_label')
    [g, w, l]
  else
    null

gameUpdateCallCleanUp = (t) ->
  $(t).prop('disabled', false)
  $('button#update_bracket').on 'click', (e) => sendGameUpdates e

gameUpdateError = (errorThrown, textStatus, t) ->
  showError errorThrown, textStatus
  gameUpdateCallCleanUp(t)

gameUpdateSetup = (e) ->
  e.preventDefault()
  $('div.success').text('').removeClass('success')
  target = e.target
  $(target).prop('disabled', true)
  bId = $('table.bracket').data 'bracket_id'
  [target, bId]

gameUpdateSuccess = (bId, t) ->
  clearNewGameChoiceFlags bId
  reloadPage()
  gameUpdateCallCleanUp(t)

getAncestors = (n) ->
  a = Store.get 'a_' + n
  a? or a = []
  a

getBracketEntry = (bId, n) ->
  e = Store.get(buildLocalStoreLabel(bId, n, 'name'))
  if e?
    name = e
    e = n
  else
# use value stored in 'winner' slot
    e = Store.get(buildLocalStoreLabel(bId, n, 'winners_label'))
    name = Store.get(buildLocalStoreLabel(bId, e, 'name'))
  !name? and name = ''
  !e? and e = ''
  [name, e]

getDescendant = (n) ->
  d = Store.get 'd_' + n
  d? or d = ''
  d

loadBracket = (e) ->
  loadBracketData()
  loadBracketAncestors()
  return

loadBracketAncestors = ->
  ancestors = $('table.bracket').data 'ancestors'
  storeAncestorData(n, a) for n,a of ancestors
  return

loadBracketData = ->
# Using jQuery.one() means we *must* clear the data-bracket attribute
# before continuing.
  data = $('table.bracket').data 'bracket'
  bracketId = data.id
  localStore(bracketId, node) for node in data.nodes
  $('table.bracket').data 'bracket', ''
  $('table.bracket').data 'bracket_id', bracketId
  return

localStore = (i, n) ->
  pairs = buildLocalStorePairs i, n
  Store.set p[0], p[1] for p in pairs
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
      reloadPage()
    error: (jqXHR, textStatus, errorThrown) ->
      showError errorThrown, textStatus

nameTeam = (target) ->
  sendTeamNameUpdate(t) for t in $(target)

reloadPage = () ->
  window.location.reload()

sendGameUpdates = (e) ->
  [target, bId] = gameUpdateSetup(e)
  # gotta "" the game_data key, otherwise JSON parsing barfs on the server
  $.ajax
    contentType: 'application/json'
    type: 'PUT'
    url: $(target).closest('form').attr('action')
    data: JSON.stringify({"bracket": {"game_data": buildGameData(bId)}})
    success: (data, textStatus, jqXHR) ->
      gameUpdateSuccess(bId, target)
    error: (jqXHR, textStatus, errorThrown) ->
      gameUpdateError(errorThrown, textStatus, target)
  return false

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
      reloadPage()
    error: (jqXHR, textStatus, errorThrown) ->
      showError errorThrown, textStatus
      wipeTextField target

showError = (errorThrown, textStatus) ->
  alert errorThrown

storeAncestorData = (node, ancestors) ->
  Store.set 'a_' + node, ancestors
  Store.set 'd_' + a, node for a in ancestors
  return

teamUpdateSetup = (t) ->
  newName = t.value
  node = $(t).closest('td').data('node')
  teamId = $(t).next()[0].value
  bracketId = $('table.bracket').data 'bracket_id'
  !bracketId? and bracketId = $('table.bracket').data('bracket').id
  [teamId,bracketId,node,newName]

updateLocalBracket = (input) ->
  n = input.node
  bId = input.bracket_id
  if input.name?
    Store.set(buildLocalStoreLabel(bId, n, 'name'), input.name)
  else if input.winner?
    Store.set(buildLocalStoreLabel(bId, n, 'winner'), input.winner)
    Store.set(buildLocalStoreLabel(bId, n, 'winners_label'), input.winners_label)
    Store.set(buildLocalStoreLabel(bId, n, 'is_new'), yes)
  # input.node contains the node being updated, so have to lookup descendant
  # to know which to update consequently
  while  d = getDescendant n
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
  $('button#submit_games').on 'click', (e) => sendGameUpdates e
  $('button#update_bracket').on 'click', (e) => sendGameUpdates e
  $('button#lock_players_brackets').on 'click', (e) => lockPlayersBrackets e
  $('table.bracket').one 'focusin', (e) => loadBracket e.target

