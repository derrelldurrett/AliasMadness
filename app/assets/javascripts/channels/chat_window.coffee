#= require_self
#= require common
# Behavior for driving the sizing of the heckle forum window, and the setup of the autocomplete
# feature for the chat window.
# Chat Window behavior
class ChatWindowDriver
  constructor: () ->
    @loadChatNames()
    @initChatAutocomplete()

  addActive: (elems) ->
    return unless elems?
    (elem.classList.remove 'autocomplete-active') for elem in elems
    @currentFocus = 0 if @currentFocus >= elems.length
    @currentFocus = elems.length - 1 if @currentFocus < 0
    elems[@currentFocus].classList.add 'autocomplete-active'

  checkInput: (event) ->
    if event.originalEvent.data is '@'
      @initChatTargetList(event)
    else if @atSignLoc >= 0
      @resetAutocomplete(false)
      autocompDiv = @initAutocompDiv(event.target)
      # Do something with @chatters
      @handleChatAutos(c, event.target, autocompDiv) for c in @chatters.autocompleteList

  # the hidden inputs attached to the div for the chat to send need to have their tags converted to a list of ids
  collectTargetIds: () ->
    (i.value) for i in $('input.to-id')

  handleChatAutos: (chatter, targ, div) ->
    t = targ.textContent.substr(@atSignLoc)
    if chatter.substr(0,t.length-1).toUpperCase() is t.substr(1).toUpperCase()
      div.appendChild @makeAutocompleteEntry(chatter, t)

  handleNonInput: (event) ->
    x = document.getElementById event.target.id + 'autocomplete-list'
    x = x.getElementsByTagName("div") if x?
    switch event.which # remarkably, event.keyCode is not useful in many contexts.
      when 40 # down arrow
        @currentFocus++ #increase the currentFocus variable
        @addActive(x) # and highlight the current item:
      when 38
        @currentFocus-- # decrease the currentFocus variable:
        @addActive(x) # and highlight the current item:
      when 8 # backspaces mean we need to watch how far back we go
        @resetAutocomplete() if @chatInput.textContent.length <= @atSignLoc + 1
      when 13
        # If the ENTER key is pressed, prevent the form from being submitted,
        event.preventDefault()
        if @currentFocus > -1
          # and simulate a click on the "active" item:
          x[@currentFocus].click() if x?
        else if $('div.autocomplete-items').size() == 1
          x[0].click() if x?
        else
          @sendChat(event)

  highlightFromUser: ->
    uid = $('div#chat-text').attr('data-uid')
    @tagIfMe($(h), uid) for h in $('div.heckles')

  initAutocompDiv: (targ) ->
    autocompDiv = document.createElement("div")
    autocompDiv.setAttribute("id", targ.id + "autocomplete-list")
    autocompDiv.setAttribute("class", "autocomplete-items")
    targ.parentNode.appendChild autocompDiv
    autocompDiv

  initChatAutocomplete: () ->
    @resetAutocomplete()
    @chatInput = document.getElementById('chat-text')
    $('#chat-text').on 'keydown', (e) => @handleNonInput(e)
    $('#chat-text').on 'input', (e) => @checkInput(e)

  initChatTargetList: (event) ->
    @resetAutocomplete()
    t = event.target
    @atSignLoc = t.textContent.length - 1
    @preceeding = t.innerHTML.substr(0, t.innerHTML.length - 1)

  insertAndCloseAutocomplete: (chatter, autocompItem) ->
    # Weirdly, this value is different on Chrome versus Firefox....
    displayMe = if chatter.startsWith('@') then chatter else '@'+chatter
    console.log("preceeds: #{@preceeding}")
    console.log("#{chatter} became #{displayMe}")
    #insert the value for the autocomplete text field:
    @chatInput.innerHTML = "#{@preceeding}<strong>#{displayMe}</strong>&nbsp;"
    autocompItem.innerHTML = "<input class='to-id' type='hidden' value='#{@chatters.getIdForChatter(chatter)}' />"
    @chatInput.appendChild autocompItem
    @setCaret(@chatInput)
    @resetAutocomplete() # close the list of autocompleted values

  isChatter: (seg) ->
    seg.startsWith('@') and @chatters.autocompleteList.includes(seg.substr(1, seg.indexOf('&')-1))

  loadChatNames: ->
    @chatters = new ChatLookup $('#chat-text').data('chat-name-lookup')

  makeAutocompleteEntry: (chatter, targ) ->
    autocompItem = document.createElement("div")
    autocompItem.innerHTML = "<strong>@#{chatter.substr(0,targ.length-1)}</strong>#{chatter.substr(targ.length-1)}"
    autocompItem.addEventListener "click", (e) => @insertAndCloseAutocomplete(chatter, autocompItem)
    autocompItem

  removeAutocompleteItems: () ->
    ai.parentNode.removeChild(ai) for ai in document.getElementsByClassName("autocomplete-items")

  resetAutocomplete: (resetAtSign = true) ->
    @curChatTarget = ''
    @chatAutoList = []
    @currentFocus = -1
    @atSignLoc = -1 if resetAtSign
    @removeAutocompleteItems()

  sendChat: (event) ->
    t = event.target
    unless t.textContent is ''
      Chats.forum.heckle t.textContent, t.dataset.uid, @collectTargetIds()
    t.textContent = ''

  # https://jsfiddle.net/timdown/vXnCM/
  setCaret: (element) ->
    range = document.createRange()
    sel = window.getSelection()
    range.setStart(element.childNodes[element.childNodes.length-2], 1)
    range.collapse(true)
    sel.removeAllRanges()
    sel.addRange(range)
    element.focus()

  setChatDimensions: ->
    @setWidths()
    @setHeights()

  setHeight: (source, targets) ->
    height = 0
    $(source).each (index, element) =>
      height += $(element).height()
    $(t).css('height', height) for t in targets

  setHeights: ->
    @setHeight('td.chat-header', ['div#chat-header-anchor']) # header
    @setHeight('tr.chat-receipt', ['div#chats-received']) # receipt
    @setHeight('tr.chat-sending', ['div#chat-send', 'div#chat-text']) # send

  setWidths: ->
    curWidth = 0
    # should consider giving the <td>s in question a common class and iterate over that.
    (curWidth += $('td[data-node="'+n+'"]').width() for n in ["5", "2", "1", "3", "7"])
    curWidth -= 20 # Because of the margins we want
    $('div[id^="chat"]').each (index, element) =>
      $(element).css("width", curWidth)
    $('div#chat-text').each (index, element) =>
      $(element).css("width", curWidth)

  tagIfMe: (heckleDiv, uid) ->
    heckleDiv.addClass('from-me-in-chat') if heckleDiv.attr('data-sid') == uid

$ ->
  chatDriver = new ChatWindowDriver
  chatDriver.setChatDimensions()
  chatDriver.highlightFromUser()
  $('#chat-text').on 'input', (e) => chatDriver.checkInput(e)
  $('#bracket').on 'click', (e) -> chatDriver.resetAutocomplete()
  # force the newest chat into view
  document.getElementById('chat-anchor').scrollIntoView()

