class Chatter
  constructor: () ->
    @chatLookups = new ChatLookup $('#chat-text').data('chat-name-lookup')

  connected: ->

  disconnected: ->

  # has to return the DOM to add.
  markUpHeckle: (heckle) ->
    h = $(heckle)
    h = h.addClass('from-me-in-chat') if h.attr('data-sid') is $('div#chat-text').attr('data-uid')
    h

  received: (data) ->
    $('.heckles').first().remove() while $('.heckles').size() >= 100 # permit only 100
    h = @markUpHeckle(data.heckle)
    h.insertBefore $('#chat-anchor')
    document.getElementById('chat-anchor').scrollIntoView()

class ForumChatter extends Chatter
  channel: ->
    channel: "ForumChannel"
    room: 'common_room'

  heckle: (message, uid, targets) ->
    @perform 'heckle', message: message, id: uid, targets: targets

class PrivateChatter extends Chatter
  channel: ->
    channel: "PrivateChannel"
    room: $('table.bracket').data 'chat'

$ ->
  $(document).on 'turbolinks:load', ->
    chatter = new ForumChatter
    Chats.forum = Chats.cable.subscriptions.create chatter.channel(), chatter

    chatter = new PrivateChatter
    Chats.privt = Chats.cable.subscriptions.create chatter.channel(), chatter