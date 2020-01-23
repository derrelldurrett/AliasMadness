class @Common
  @reloadPage: () ->
    window.location.reload()

  @showError: (errorThrown, textStatus) ->
    alert errorThrown

