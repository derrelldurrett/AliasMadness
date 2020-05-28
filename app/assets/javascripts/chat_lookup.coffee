class @ChatLookup
  constructor: (nameIdMap) ->
    @map = {}
    @autocompleteList = []
    @buildLists(nameId) for nameId in nameIdMap

  # Build a lookup for id given the name, plus the autocompletes
  buildLists: (nameId) ->
    [name, id] = nameId
    @map[name] = id
    @autocompleteList.push name

  # get the ID for the name
  getIdForChatter: (name) ->
    @map[name]

