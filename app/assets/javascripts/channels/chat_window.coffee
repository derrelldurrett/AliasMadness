# Behavior for driving the sizing of the heckle forum window.
#= require_self
#= require common
class ChatWindowDriver
  @setChatDimensions: ->
    @setWidths()
    @setHeights()

  @loadChatNames: ->
    new ChatLookup $('#chat-text').data('chat-name-lookup')

  @sendChat: (event, chatters) ->
    if event.keyCode is 13
      unless event.target.textContent is ''
        Chats.forum.heckle event.target.textContent, event.target.dataset.uid
      event.target.textContent = ''
      event.preventDefault()

  @setWidths: ->
    curWidth = 0
    (curWidth += $('td[data-node="'+n+'"]').width() for n in ["5", "2", "1", "3", "7"])
    curWidth -= 20 # Because of the margins we want
    $('div[id^="chat"]').each (index, element) =>
      $(element).css("width", curWidth)
    $('div#chat-text').each (index, element) =>
      $(element).css("width", curWidth)

  @setHeights: ->
    @setHeight('td.chat-header', ['div#chat-header-anchor']) # header
    @setHeight('tr.chat-receipt', ['div#chats-received']) # receipt
    @setHeight('tr.chat-sending', ['div#chat-send', 'div#chat-text']) # send

  @setHeight: (source, targets) ->
    height = 0
    $(source).each (index, element) =>
      height += $(element).height()
    $(t).css('height', height) for t in targets

$ ->
  ChatWindowDriver.setChatDimensions()
  chatters = ChatWindowDriver.loadChatNames()
  $('#chat-text').on 'keypress', (e) => ChatWindowDriver.sendChat(e, chatters)
  document.getElementById('chat-anchor').scrollIntoView()

