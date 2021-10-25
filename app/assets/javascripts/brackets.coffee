#= require_self
#= require common
#= require game_update
#= require bracket_games
class @Bracket
  fixTeamNames: (e) ->
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

  loadBracket: (e) ->
    @loadBracketData()
    @loadBracketAncestors()

  loadBracketAncestors: ->
    ancestors = $('table.bracket').data 'ancestors'
    StoreWrapper.setAncestorData(n, a) for n, a of ancestors

  loadBracketData: ->
    data = $('table.bracket').data 'bracket'
    bracketId = data.id
    StoreWrapper.localStore(bracketId, node) for node in data.nodes
    # Using jQuery.one() means we *must* clear the data-bracket attribute before continuing.
    $('table.bracket').data 'bracket', ''
    $('table.bracket').data 'bracket_id', bracketId

  lockPlayersBrackets: (e) ->
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

  nameTeam: (target) ->
    @sendTeamNameUpdate(t) for t in $(target)

  sendTeamNameUpdate: (target) ->
    [teamId,bracketId,node,newName] = @teamUpdateSetup target
    bracketGames = new BracketGame()
    bracket = this
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
        bracketGames.updateLocalBracket node: node, data: data, name: newName, bracket_id: bracketId
        Common.reloadPage()
      error: (jqXHR, textStatus, errorThrown) ->
        Common.showError errorThrown, textStatus
        bracket.wipeTextField target

  teamUpdateSetup: (t) ->
    newName = t.value
    node = $(t).closest('td').data('node')
    teamId = $(t).next()[0].value
    bracketId = $('table.bracket').data 'bracket_id'
    !bracketId? and bracketId = $('table.bracket').data('bracket').id
    [teamId,bracketId,node,newName]

  wipeTextField: (targetNode) ->
    targetNode.value = ''

$ ->
  bracket = new Bracket()
  $('button#submit_games').on 'click', (e) => GameUpdate.sendGameUpdates e
  $('table.bracket').one 'focusin', (e) => bracket.loadBracket e.target

