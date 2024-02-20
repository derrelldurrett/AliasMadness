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

  @gameUpdateError: (errorThrown, textStatus) ->
    Common.showError errorThrown, textStatus
    @installGameUpdateClickHandler

  @gameUpdateSetup: (e) ->
    e.preventDefault()
    $('div.success').text('').removeClass('success')
    target = e.target
    $(target).prop('disabled', true)
    bId = $('table.bracket').data 'bracket_id'
    [target, bId]

  @gameUpdateSuccess: (bId) ->
    @clearNewGameChoiceFlags bId
    @installGameUpdateClickHandler

  @installGameUpdateClickHandler = () ->
    $('button#update_bracket').on 'click', (e) => @sendGameUpdates e

  @sendGameUpdates: (e) ->
    [target, bId] = @gameUpdateSetup e
    sendMe = @buildGameData bId
    $.ajax
      contentType: 'application/json'
      type: 'PUT'
      url: $(target).closest('form').attr('action')
      data: JSON.stringify {"bracket": {"game_data": sendMe}}
      success: (data, textStatus, jqXHR) ->
        GameUpdate.gameUpdateSuccess bId
      error: (jqXHR, textStatus, errorThrown) ->
        GameUpdate.gameUpdateError errorThrown, textStatus
      complete: (jqXHR, textStatus) ->
        Common.reloadPage()
        $(target).prop('disabled', false)

    return false

$ ->
  GameUpdate.installGameUpdateClickHandler()
