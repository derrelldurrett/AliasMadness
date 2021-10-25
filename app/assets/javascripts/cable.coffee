#= require action_cable
#= require_self
#= require_tree ./channels
#= require ./channels/game_updater
# Chat subscription cables
@Chats ||= {}
@Chats.cable = ActionCable.createConsumer()
@Chats.forum = ''
@Chats.privt = ''

# Game update subscription cables
@GameUpdaters ||= {}
@GameUpdaters.cable = ActionCable.createConsumer()
@GameUpdaters['game_updater_'+gameUpdaterId] = '' for gameUpdaterId in [1..63]

$ ->
  $(document).on 'turbolinks:load', ->
    # one for each game?
    GameUpdater.buildGameUpdaters()
