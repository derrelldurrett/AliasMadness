Chats.forum = Chats.cable.subscriptions.create "ForumChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    $('.heckles').first().remove() if $('.heckles').size() > 100 # reduce the number
    $(data.heckle).insertBefore $('#chat-anchor')
    document.getElementById('chat-anchor').scrollIntoView()

  heckle: (message, uid) ->
    @perform 'heckle', message: message, id: uid
