class ChatLookup
  constructor: (nameIdMap) ->
    @map = {}
    @autoCompleteList = []
    buildLists(nameId) for nameId in nameIdMap

  buildLists: (nameId) ->
    [name, id] = nameId
    @map[name] = id
    @autoCompleteList.push name

