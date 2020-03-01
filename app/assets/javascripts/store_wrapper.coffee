#= require store-master/store

class @StoreWrapper
  @attrExists: (bId, g, attr) ->
    Store.get(@buildLocalStoreLabel(bId, g, attr))?

  @buildLocalStoreLabel: (bid, node, attr) ->
    "#{bid}_#{node}_#{attr}"

  @buildLocalStorePairs: (i, n) ->
    localStorePairs = for name, val of n when name isnt 'label'
      [@buildLocalStoreLabel(i, n.label, name), val]
    localStorePairs

  @getAncestors: (n) ->
    a = Store.get 'a_' + n
    a? or a = []
    a

  @getDescendant: (n) ->
    d = Store.get 'd_' + n
    d? or d = ''
    d

  @getStoreName: (bId, l) ->
    Store.get(@buildLocalStoreLabel(bId, l, 'name'))

  @getStoreWinner: (bId, l) ->
    Store.get(@buildLocalStoreLabel(bId, l, 'winner'))

  @getStoreWinnersLabel: (bId, l) ->
    Store.get(@buildLocalStoreLabel(bId, l, 'winners_label'))

  @localStore: (i, n) ->
    pairs = @buildLocalStorePairs i, n
    Store.set p[0], p[1] for p in pairs

  @setAncestorData: (node, ancestors) ->
    Store.set 'a_' + node, ancestors
    Store.set 'd_' + a, node for a in ancestors

  @setStoreName: (bId, l, name) ->
    Store.set(@buildLocalStoreLabel(bId, l, 'name'), name)

  @setStoreNew: (bId, l) ->
    Store.set(@buildLocalStoreLabel(bId, l, 'is_new'), yes)

  @setStoreWinner: (bId, l, winner) ->
    Store.set(@buildLocalStoreLabel(bId, l, 'winner'), winner)

  @setStoreWinnersLabel: (bId, l, winners_label) ->
    Store.set(@buildLocalStoreLabel(bId, l, 'winners_label'), winners_label)

  @updateStore: (input) ->
    n = input.node
    bId = input.bracket_id
    if input.name?
      @setStoreName(bId, n, input.name)
    else if input.winner?
      @setStoreWinner(bId, n, input.winner)
      @setStoreWinnersLabel(bId, n, input.winners_label)
      @setStoreNew(bId, n)

  @noop: ->
    ''