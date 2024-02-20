# Class and class methods for updating team names
#= require admin
#= require common
#= require store_wrapper
#= require store-master/store
class @TeamNameUpdate
  @buildTeamUpdate = (input) ->
    teamUpdateData =
      "team[name]":    input.newName
      "bracket[id]":   input.bracketId
      "bracket[node]": input.node
    teamUpdateData

  @changeTeamName = (e, onSuccess, onError) ->
    e.preventDefault()
    $('div.success').text('').removeClass('success')
    target = e.target
    $(target).prop('disabled', true)
    bId = $('table.bracket').data 'bracket_id'
    @sendTeamNameUpdate(t, onSuccess, onError) for t in $(target)

  @sendTeamNameUpdate = (target, onSuccess, onError) ->
    [bracketId,node,newName] = @teamUpdateSetup target
    return if newName == ''
    teamUpdateData = @buildTeamUpdate newName: newName, bracketId: bracketId, node: node
    $.ajax
      type: 'PUT'
      url: $(target).closest('form').attr('action')
      beforeSend: (xhr) ->
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
      data: {"bracket": {"team_data": teamUpdateData}}
      success: (data, textStatus, jqXHR) ->
        onSuccess node: node, data: data, name: newName, bracket_id: bracketId
      error: (jqXHR, textStatus, errorThrown) ->
        onError err: errorThrown, tStatus: textStatus, tar: target

  @lockTeamNames = (e) ->
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

  @teamUpdateSetup = (t) ->
    newName = t.value
    node = $(t).closest('td').data('node')
    bracketId = $('table.bracket').data 'bracket_id'
    !bracketId? and bracketId = $('table.bracket').data('bracket').id
    [bracketId,node,newName]

