#= require action_cable
#= require_self
#= require_tree ./channels
#
# Chat subscription cables
@Chats ||= {}
@Chats.cable = ActionCable.createConsumer()
@Chats.forum = ''
@Chats.privt = ''

# Game update subscription cables
@GameUpdaters ||= {}
@GameUpdaters.cable = ActionCable.createConsumer()
@GameUpdaters['game_updater_'+gameUpdaterId] = '' for gameUpdaterId in [1..63]