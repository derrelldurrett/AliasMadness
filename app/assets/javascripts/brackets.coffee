# Place all the behaviors and hooks related to the matching controller here.
#= require_self
#= require store-master/store
chooseWinnerString = 'Choose winner...'
nameTeam = (target) ->
  clearMessages()
  sendTeamNameUpdate(t) for t in $(target)

sendTeamNameUpdate = (target) ->
  newName = target.value
  node = $(target).closest('td').data('node')
  teamId = $(target).next()[0].value
  bracketId = $('table.bracket').data 'bracket_id'
  !bracketId? and bracketId= $('table.bracket').data('bracket').id
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
    error: (jqXHR, textStatus, errorThrown) ->
      showError jqXHR, textStatus, errorThrown
      wipeTextField target

wipeTextField = (targetNode) ->
  targetNode.value= ''

showError = (jqXHR, textStatus, errorThrown) ->
#  $('div#messages').empty()
  alert('error-- see console log');
  window.open("", "MsgWindow", "width=200, height=100").document.write(jqXHR.responseText);

reloadPage = (w) ->
  w.location.reload(true)

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
      reloadPage window
    error: (jqXHR, textStatus, errorThrown) ->
      showError jqXHR, textStatus, errorThrown


acceptWinner = (w) ->
  w? and w isnt chooseWinnerString

setWinnerInLocalStore = (bId, n, input) ->
  winner = null
  winners_label = null
  if input? and acceptWinner input.winners_label
    winner = input.winner
    winners_label = input.winners_label
  Store.set(buildLocalStoreLabel(bId, n, 'winner'), winner)
  Store.set(buildLocalStoreLabel(bId, n, 'winners_label'), winners_label)
  Store.set(buildLocalStoreLabel(bId, n, 'is_new'), true)

updateLocalBracket = (input) ->
  n = input.node
  bId = input.bracket_id
  if input.name?
    Store.set(buildLocalStoreLabel(bId,n,'name'), input.name)
  else if input.winner?
    setWinnerInLocalStore(bId, n, input)
    # input.node contains the node being updated, so have to lookup descendant
    # to know which to update consequently
    updateDescendants(bId, getDescendant n)
  return

updateDescendants = (bId, d) ->
  while d?
    $gameNode= $('select#game_'+d)
    $gameNode.empty()
    $gameNode.append($.parseHTML(buildSelectOptionsFor bId, d))
    setWinnerInLocalStore(bId, d, null)
    d = getDescendant d


getAncestors = (n) ->
  a= Store.get 'a_'+n
  a? or a= []
  a

getDescendant = (n) ->
  d= Store.get 'd_'+n
  #  d? or d= ''
  d

buildSelectOptionsFor= (bracketId, node) ->
  optionString='<option value>Choose winner...</option>'
  optionString+= buildOption(bracketId,ancestor) for ancestor in getAncestors(node)
  optionString

buildOption= (bId,n) ->
  [displayName,value]= getBracketEntry(bId,n)
  "\n"+'<option value="'+value+'">'+displayName+'</option>'

getBracketEntry= (bId,n) ->
  e= Store.get(buildLocalStoreLabel(bId,n,'name'))
  if e?
    name=e
    e=n
  else
    # use value stored in 'winner' slot
    e= Store.get(buildLocalStoreLabel(bId,n,'winners_label'))
    name= Store.get(buildLocalStoreLabel(bId,e,'name'))
  !name? and name=''
  !e? and e=''
  [name,e]

chooseWinner = (target) ->
  clearMessages()
  updateOptions(t) for t in $(target)
  return

clearMessages = ->
  $('div#messages').empty()

updateOptions = (target) ->
  node = $(target).attr 'node'
  winnerLabel= $(target).find(':selected').val() # an integer, the label of the winning team
  bId= $('table.bracket').data 'bracket_id'
  winner = $(target).find(':selected').text()
  resetWinnerIfChooseWinnerString(winner, winnerLabel)
  updateLocalBracket({node: node, winner: winner, bracket_id: bId, winners_label: winnerLabel})
  return

resetWinnerIfChooseWinnerString = (winner, winnerLabel) ->
  if winner is chooseWinnerString or winnerLabel is chooseWinnerString
    winner = null
    winnerLabel = null


localStore = (i,n) ->
  pairs = buildLocalStorePairs i,n
  Store.set p[0],p[1] for p in pairs
  return

buildLocalStorePairs = (i,n) ->
  localStorePairs= for name, val of n when name isnt 'label'
    [buildLocalStoreLabel(i,n.label,name), val]
  localStorePairs

buildLocalStoreLabel = (bid,node,attr) ->
  "#{bid}_#{node}_#{attr}"

storeAncestorData = (node, ancestors) ->
  Store.set 'a_'+node, ancestors
  Store.set 'd_'+a, node for a in ancestors
  return

loadBracket = (e) ->
  loadBracketData()
  loadBracketAncestors()
  return

loadBracketData = ->
  # Using jQuery.one() means we *must* clear the data-bracket attribute
  # before continuing.
  data = $('table.bracket').data 'bracket'
  if data?
    bracketId = data.id
    clearNewGameChoiceFlags(bracketId)
    localStore(bracketId, node) for node in data.nodes
    $('table.bracket').data 'bracket', null
    $('table.bracket').data 'bracket_id', bracketId
  return

loadBracketAncestors = ->
  ancestors = $('table.bracket').data 'ancestors'
  storeAncestorData(n,a) for n,a of ancestors
  return

hasNewGameData = (g, bId) ->
  if attrExists(bId,g,'is_new')
    w= Store.get buildLocalStoreLabel(bId,g,'winner')
    l= Store.get buildLocalStoreLabel(bId,g,'winners_label')
    w = null if w is chooseWinnerString
    l = null if l is chooseWinnerString
    [g,w,l]
  else
    null

expireAttr= (bId,g,attr) ->
  Store.expire(buildLocalStoreLabel(bId,g,attr))

attrExists= (bId,g,attr) ->
  Store.get(buildLocalStoreLabel(bId,g,attr))?

clearNewGameChoiceFlags= (bId) ->
  expireAttr(bId,g,'is_new') for g in [63..1] when attrExists(bId,g,'is_new')

sendGameUpdates = (e, expectDone = false) ->
  e.preventDefault();
  target= e.target
  bId= $('table.bracket').data 'bracket_id'
  sendMe = (gameDataCached for g in [63..1] when (gameDataCached = hasNewGameData(g, bId))?)
  # gotta "" the game_data key, otherwise JSON parsing barfs on the server
  $.ajax
    contentType: 'application/json'
    type: 'PUT'
    url: $(target).closest('form').attr('action')
    data:
      JSON.stringify({"game_data": sendMe})
    success: (data, textStatus, jqXHR) ->
      clearNewGameChoiceFlags bId
      reloadPage window
      highlightUnchosenGames(bId) if expectDone
    error: (jqXHR, textStatus, errorThrown) ->
      showError jqXHR, textStatus, errorThrown
  return false

highlightUnchosenGames = (bId) ->
  highlightGame(g) for g in [63..1] when (gameDataCached = hasNoWinnerGameData(g, bId)?)

hasNoWinnerGameData = (g, bId) ->
  w = Store.get buildLocalStoreLabel(bId, g, 'winner')
  l = Store.get buildLocalStoreLabel(bId, g, 'winners_label')
  if winnerNotSet(w) and winnerNotSet(l)
    return g
  return

winnerNotSet = (w) ->
  !w? or w is '' or w is chooseWinnerString

highlightGame = (g) ->
  $("td.game[data-node=\"#{g}\"] select#game_#{g}").addClass('not-done')

lockPlayersBrackets = (e) ->
  e.preventDefault();
  $.ajax
    contentType: 'application/json'
    type: 'PUT'
    url: '/lock_players_brackets'
    beforeSend: (xhr) ->
      xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
    data: JSON.stringify({"lock_players_brackets": true})
    success: (data, textStatus, jqXHR) ->
      reloadPage window
    error: (jqXHR, textStatus, errorThrown) ->
      showError jqXHR, textStatus, errorThrown


$ ->
  $('input.team_name').on 'change', (e) => nameTeam e.target
  $('select.game_winner').on 'change', (e) => chooseWinner e.target
  $('button#team_entry_done').on 'click', (e) => fixTeamNames e
  $('button#submit_games').on 'click', (e) => sendGameUpdates e, true
  $('button#update_bracket').on 'click', (e) => sendGameUpdates e, false
  $('button#lock_players_brackets').on 'click', (e) => lockPlayersBrackets e
  $('table.bracket').one 'focusin', (e) => loadBracket e.target
