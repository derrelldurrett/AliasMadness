# Place all the behaviors and hooks related to the matching controller here.
#= require_self
#= require store-master/store
nameTeam = (target) ->
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
      reloadPage window
    error: (jqXHR, textStatus, errorThrown) ->
      showError errorThrown, textStatus
      wipeTextField target

wipeTextField = (targetNode) ->
  targetNode.value= ''

showError = (errorThrown,textStatus) ->
  alert errorThrown

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
      showError errorThrown, textStatus

updateLocalBracket = (input) ->
  n=input.node
  bId=input.bracket_id
  if input.name?
    Store.set(buildLocalStoreLabel(bId,n,'name'), input.name)
  else if input.winner?
    Store.set(buildLocalStoreLabel(bId,n,'winner'), input.winner)
    Store.set(buildLocalStoreLabel(bId,n,'winners_label'), input.winners_label)
    Store.set(buildLocalStoreLabel(bId,n,'is_new'), yes)
  # input.node contains the node being updated, so have to lookup descendant
  # to know which to update consequently
  d = getDescendant n
  if d?
    $gameNode= $('select#game_'+d)
    $gameNode.empty()
    $gameNode.append($.parseHTML(buildSelectOptionsFor bId, d))
  return

getAncestors = (n) ->
  a= Store.get 'a_'+n
  a? or a= []
  a

getDescendant = (n) ->
  d= Store.get 'd_'+n
  d? or d= ''
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
  updateOptions(t) for t in $(target)
  return

updateOptions = (target) ->
  node = $(target).attr 'node'
  winnerLabel= $(target).find(':selected').val() # an integer, the label of the winning team
  bId= $('table.bracket').data 'bracket_id'
  winner= $(target).find(':selected').text() # Store.get(buildLocalStoreLabel(bId,winnerLabel,'name'))
  updateLocalBracket({node: node, winner: winner, bracket_id: bId,winners_label: winnerLabel})
  return

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

gameData= (g,bId) ->
  if attrExists(bId,g,'is_new')
    w= Store.get buildLocalStoreLabel(bId,g,'winner')
    l= Store.get buildLocalStoreLabel(bId,g,'winners_label')
    [g,w,l]
  else
    null

expireAttr= (bId,g,attr) ->
  Store.expire(buildLocalStoreLabel(bId,g,attr))

attrExists= (bId,g,attr) ->
  Store.get(buildLocalStoreLabel(bId,g,attr))?

clearNewGameChoiceFlags= (bId) ->
  expireAttr(bId,g,'is_new') for g in [63..1] when attrExists(bId,g,'is_new')

sendGameUpdates = (e) ->
  e.preventDefault();
  target= e.target
  bId= $('table.bracket').data 'bracket_id'
  sendMe= (gameDataCached for g in [63..1] when (gameDataCached= gameData(g,bId))?)
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
    error: (jqXHR, textStatus, errorThrown) ->
      showError errorThrown, textStatus
  return false

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
      showError errorThrown, textStatus


$ ->
  $('input.team_name').on 'change', (e) => nameTeam e.target
  $('select.game_winner').on 'change', (e) => chooseWinner e.target
  $('button#team_entry_done').on 'click', (e) => fixTeamNames e
  $('button#submit_games').on 'click', (e) => sendGameUpdates e
  $('button#update_bracket').on 'click', (e) => sendGameUpdates e
  $('button#lock_players_brackets').on 'click', (e) => lockPlayersBrackets e
  $('table.bracket').one 'focusin', (e) => loadBracket e.target
