# Behavior for driving the sizing of the heckle forum window.
#= require_self
#= require common
class ChatWindowDriver
  @setChatWidths: () ->
    curWidth = 0
    (curWidth += $('td[data-node="'+n+'"]').width() for n in ["5", "2", "1", "3", "7"])
    curWidth -= 20 # Because of the margins we want
    $('div[id^="chat"]').each (index, element) =>
      $(element).css("width", curWidth)
    $('textarea#chat-text').each (index, element) =>
      $(element).css("width", curWidth)
    headerHeight = 0
    $('td.chat-header').each (index, element) =>
      headerHeight += $(element).height()
    $('div#chat-header-anchor').css('height', headerHeight)
    receiptHeight = 0
    $('tr.chat-receipt').each (index, element) =>
      receiptHeight += $(element).height()
    $('div#chats-received').css('height', receiptHeight)
    sendingHeight = 0
    $('tr.chat-sending').each (index, element) =>
      sendingHeight += $(element).height()
    $('div#chat-send').css('height', sendingHeight)

  @sendChat: (event) ->
    if event.keyCode is 13 # return/enter => send
      Chats.forum.heckle event.target.value
      event.target.value = ''
      event.preventDefault()

$ ->
  console.log 'can we see this message?'
  ChatWindowDriver.setChatWidths()
  $('#chat-text').on 'keypress', (e) => ChatWindowDriver.sendChat(e)