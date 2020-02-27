Chats.forum = Chats.cable.subscriptions.create "ForumChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    $(data.heckle).insertBefore $('#chat-anchor')

  heckle: (merciless_heckle, uid) ->
    @perform 'heckle', message: merciless_heckle, id: uid
