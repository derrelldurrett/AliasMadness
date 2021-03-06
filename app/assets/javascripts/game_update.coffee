# Class and class methods for updating game data
#= require admin
#= require common
#= require store_wrapper
#= require store-master/store
class @GameUpdate
  @buildGameData: (bId) ->
    (gameDataCached for g in [63..1] when (gameDataCached = @gameData(g, bId))?)

  @clearNewGameChoiceFlags: (bId) ->
    @expireAttr(bId, g, 'is_new') for g in [63..1] when StoreWrapper.attrExists(bId, g, 'is_new')

  @expireAttr: (bId, g, attr) ->
    Store.expire(StoreWrapper.buildLocalStoreLabel(bId, g, attr))

  @gameData: (g, bId) ->
    if StoreWrapper.attrExists(bId, g, 'is_new')
      w = StoreWrapper.getStoreWinner(bId, g)
      l = StoreWrapper.getStoreWinnersLabel(bId, g)
      [g, w, l]
    else
      null

  @gameUpdateCallCleanUp: (t) ->
    installGameUpdateClickHandler()

  @gameUpdateError: (errorThrown, textStatus, t) ->
    showError errorThrown, textStatus
    @gameUpdateCallCleanUp(t)

  @gameUpdateSetup: (e) ->
    e.preventDefault()
    $('div.success').text('').removeClass('success')
    target = e.target
    $(target).prop('disabled', true)
    bId = $('table.bracket').data 'bracket_id'
    [target, bId]

  @gameUpdateSuccess: (bId, t) ->
    @clearNewGameChoiceFlags bId
    Common.reloadPage()
    @gameUpdateCallCleanUp(t)

  @sendGameUpdates: (e) ->
    [target, bId] = @gameUpdateSetup e
    sendMe = (gameDataCached for g in [63..1] when (gameDataCached = @gameData(g, bId))?)
    # gotta "" the game_data key, otherwise JSON parsing barfs on the server
    $.ajax
      contentType: 'application/json'
      type: 'PUT'
      url: $(target).closest('form').attr('action')
      data: JSON.stringify({"bracket": {"game_data": sendMe}})
      success: (data, textStatus, jqXHR) ->
        GameUpdate.clearNewGameChoiceFlags bId
        Common.reloadPage()
      error: (jqXHR, textStatus, errorThrown) ->
        Common.showError errorThrown, textStatus
      complete: (jqXHR, textStatus) ->
        $(target).prop('disabled', false)

    return false
