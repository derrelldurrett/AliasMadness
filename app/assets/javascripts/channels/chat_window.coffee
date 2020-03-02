# Behavior for driving the sizing of the heckle forum window.
#= require_self
#= require common
class ChatWindowDriver
  @checkKeyPress: (event, chatters) ->
    @sendChat(event) if event.keyCode is 13

  @loadChatNames: ->
    new ChatLookup $('#chat-text').data('chat-name-lookup')

  @sendChat: (event) ->
    t = event.target
    unless t.textContent is ''
      Chats.forum.heckle t.textContent, t.dataset.uid
    t.textContent = ''
    event.preventDefault()

  @setChatDimensions: ->
    @setWidths()
    @setHeights()

  @setHeight: (source, targets) ->
    height = 0
    $(source).each (index, element) =>
      height += $(element).height()
    $(t).css('height', height) for t in targets

  @setHeights: ->
    @setHeight('td.chat-header', ['div#chat-header-anchor']) # header
    @setHeight('tr.chat-receipt', ['div#chats-received']) # receipt
    @setHeight('tr.chat-sending', ['div#chat-send', 'div#chat-text']) # send

  @setWidths: ->
    curWidth = 0
    # should consider giving the <td>s in question a common class and iterate over that.
    (curWidth += $('td[data-node="'+n+'"]').width() for n in ["5", "2", "1", "3", "7"])
    curWidth -= 20 # Because of the margins we want
    $('div[id^="chat"]').each (index, element) =>
      $(element).css("width", curWidth)
    $('div#chat-text').each (index, element) =>
      $(element).css("width", curWidth)

$ ->
  ChatWindowDriver.setChatDimensions()
  chatters = ChatWindowDriver.loadChatNames()
  $('#chat-text').on 'keypress', (e) => ChatWindowDriver.checkKeyPress(e, chatters)
  # force the newest chat into view
  document.getElementById('chat-anchor').scrollIntoView()

