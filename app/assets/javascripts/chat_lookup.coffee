class ChatLookup
  constructor: (nameIdMap) ->
    @map = {}
    @map[nameId[0]] = nameId[1] for nameId in nameIdMap

