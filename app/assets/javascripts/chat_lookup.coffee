class @ChatLookup
  constructor: (nameIdMap) ->
    @map = {}
    @autocompleteList = []
    @buildLists(nameId) for nameId in nameIdMap

  buildLists: (nameId) ->
    [name, id] = nameId
    @map[name] = id
    @autocompleteList.push name

  getIdForChatter: (name) ->
    @map[name]
