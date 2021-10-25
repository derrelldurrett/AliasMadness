#= require_self
#= require common
# Behavior for driving the sizing of the heckle forum window, and the setup of the autocomplete
# feature for the chat window.
# Chat Window behavior
class ChatWindowDriver
  constructor: ->
    @loadChatNames()
    @initChatAutocomplete()

  # add the 'autocomplete-active' class to the active div
  addActive: (elems) ->
    return unless elems?
    (elem.classList.remove 'autocomplete-active') for elem in elems
    @currentFocus = 0 if @currentFocus >= elems.length
    @currentFocus = elems.length - 1 if @currentFocus < 0
    elems[@currentFocus].classList.add 'autocomplete-active'

  # assert the chat input text, put the cursor in place, and reset the autocomplete list
  assertText: (chatter) ->
    #insert the value for the autocomplete text field:
    @chatInput.innerHTML = "#{@preceeding}<strong>@#{chatter}</strong>&nbsp;"
    @setCaret()
    @resetAutocomplete() # close the list of autocompleted values

  # store the value of the id for the recipient in a hidden input and append to #chat-send
  appendNewInput: (chatter_id) ->
    newInput = document.createElement('input')
    newInput.className = 'to-id'
    Object.assign newInput, {type: 'hidden', value: chatter_id}
    document.getElementById('chat-send').appendChild newInput

  checkInput: (event) ->
    if event.originalEvent.data is '@'
      @initChatTargetList event
    else if @atSignLoc >= 0
      t = event.target
      @resetAutocomplete false
      autocompDiv = @initAutocompDiv t
      # Do something with @chatters
      @handleChatAutos(c, t, autocompDiv) for c in @chatters.autocompleteList
    return

  # the hidden inputs attached to the div for the chat to send need to have their tags converted to a list of ids
  collectTargetIds: ->
    (i.value) for i in document.getElementById('chat-send').querySelectorAll 'input.to-id'

  # IE specific
  createRange: (sel, doc) ->
    textRange = sel.createRange()
    preCaretTextRange = doc.body.createTextRange()
    preCaretTextRange.moveToElementText(@chatInput)
    preCaretTextRange.setEndPoint('EndToStart', textRange)
    selRge = {}
    selRge.start = preCaretTextRange.text.length
    preCaretTextRange.setEndPoint('EndToEnd', textRange)
    selRge.end = preCaretTextRange.text.length
    selRge

  # method stolen from https://stackoverflow.com/questions/4811822/get-a-ranges-start-and-end-offsets-relative-to-its-parent-container/4812022#4812022
  getSelectionRange: ->
    selRge = {start: 0, end: 0}
    doc = @chatInput.ownerDocument || @chatInput.document
    win = doc.defaultView || doc.parentWindow
    if typeof win.getSelection isnt "undefined"
      sel = win.getSelection()
      if sel.rangeCount > 0
        selRge = @useExistingRange(sel)
    else if ((sel = doc.selection) and sel.type isnt "Control") # IE specific
      selRge = @createRange(sel, doc)
    selRge

  # Shamelessly stolen from here: https://stackoverflow.com/a/29258657/1888553
  getPreceedingHTML: (editable) ->
    point = document.createTextNode "\u0001"
    document.getSelection().getRangeAt(0).insertNode point
    position = editable.innerHTML.indexOf "\u0001"
    point.parentNode.removeChild point
    editable.innerHTML.substr 0, position-1

  handleChatAutos: (chatter, targ, div) ->
    t = targ.textContent.substr @atSignLoc
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
    autocompDiv.id = "#{targ.id}autocomplete-list"
    autocompDiv.classList.add "autocomplete-items"
    autocompDiv.addEventListener "click", (e) => @insertAndCloseAutocomplete(e.target)
    targ.parentNode.appendChild(autocompDiv)
    autocompDiv

  initChatAutocomplete: ->
    @chatInput = document.getElementById('chat-text')
    @resetAutocomplete()
    $('#chat-text').on 'keydown', (e) => @handleNonInput(e)
    $('#chat-text').on 'input', (e) => @checkInput(e)

  # Be smarter: start a selection when we see an '@'
  # end a selection where the cursor is
  # figure out how to get the preceeding HTML (preserve existing formatting)
  # combine the preceeding HTML with the new bit.
  initChatTargetList: (event) ->
    @resetAutocomplete()
    @atSignLoc = @getSelectionRange().start - 1
    @preceeding = @getPreceedingHTML event.target

  insertAndCloseAutocomplete: (t) ->
    return unless t.matches 'div.autocomplete-item'
    chatter = t.value
    @appendNewInput @chatters.getIdForChatter(chatter)
    @assertText chatter

  insertRange: (range) ->
    sel = window.getSelection()
    sel.removeAllRanges()
    sel.addRange(range)

  locateRange: ->
    range = document.createRange()
    lNode = @chatInput.lastChild
    range.setStart lNode, lNode.length
    range.collapse true
    range

  loadChatNames: ->
    @chatters = new ChatLookup $('#chat-text').data('chat-name-lookup')

  makeAutocompleteEntry: (chatter, targ) ->
    autocompItem = document.createElement "div"
    autocompItem.classList.add 'autocomplete-item'
    autocompItem.value = chatter
    autocompItem.innerHTML = "<strong>@#{chatter.substr(0,targ.length-1)}</strong>#{chatter.substr(targ.length-1)}"
    autocompItem

  removeAChild: (toc) ->
    toc.parentNode.removeChild(toc)
    return # force throwing away the reference to the child

  removeNodes: (p, className) ->
    @removeAChild(c) for c in p.querySelectorAll(".#{className}")
    return # make sure we've thrown away the references to the child node

  resetAutocomplete: (resetAtSign = true) ->
    @curChatTarget = ''
    @chatAutoList = []
    @currentFocus = -1
    @atSignLoc = -1 if resetAtSign
    @removeNodes(@chatInput.parentNode, 'div.autocomplete-items')

  sendChat: (event) ->
    t = event.target
    unless t.textContent is ''
      Chats.forum.heckle t.textContent, t.dataset.uid, @collectTargetIds()
      @removeNodes(t.parentNode, "input.to-id")
    t.textContent = ''

  # https://jsfiddle.net/timdown/vXnCM/
  setCaret: ->
    range = @locateRange()
    @insertRange range
    @chatInput.focus()

  setChatDimensions: ->
    @setWidths()
    @setHeights()

  setHeight: (source, targets) ->
    height = 0
    height += $(s).height() for s in $(source)
    $(t).css('height', height) for t in targets

  setHeights: ->
    @setHeight('td.chat-header', ['div#chat-header-anchor']) # header
    @setHeight('tr.chat-receipt', ['div#chats-received']) # receipt
    @setHeight('tr.chat-sending', ['div#chat-send', 'div#chat-text']) # send

  setWidths: ->
    curWidth = -20 # Because of the margins we want
    curWidth += $(td).width() for td in $('td.chat-width-marker')
    $(d).css("width", curWidth) for d in $('div[id^="chat"]')
    $(d).css("width", curWidth) for d in $('div#chat-text')

  tagIfMe: (heckleDiv, uid) ->
    heckleDiv.addClass('from-me-in-chat') if heckleDiv.attr('data-sid') is uid

  useExistingRange: (sel) ->
    range = sel.getRangeAt 0
    preCaretRange = range.cloneRange()
    preCaretRange.selectNodeContents @chatInput
    preCaretRange.setEnd range.startContainer, range.startOffset
    selRge = {}
    selRge.start = preCaretRange.toString().length
    preCaretRange.setEnd range.endContainer, range.endOffset
    selRge.end = preCaretRange.toString().length
    selRge

$ ->
  $(document).on 'turbolinks:load', ->
    chatDriver = new ChatWindowDriver
    $('#chat-text').on 'input', (e) => chatDriver.checkInput(e)
    $('#bracket').on 'click', (e) -> chatDriver.resetAutocomplete()
    chatDriver.setChatDimensions()
    chatDriver.highlightFromUser()
    # force the newest chat into view
    document.getElementById('chat-anchor').scrollIntoView()