Storage::setObj = (key, obj) ->
  @setItem key, JSON.stringify(obj)
Storage::getObj = (key) ->
  JSON.parse @getItem(key)
$ ->
  app = new AliasMadness()

class AliasMadness
  constructor: ->
    $('.edit_team input[type="text"]').change(update_team)

  update_team: (e) ->
    $input = $(this)
    val = ($.trim $input.val())
    return unless e.which == 13 and val
    alert val

