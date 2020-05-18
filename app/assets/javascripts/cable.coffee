#= require action_cable
#= require_self
#= require_tree ./channels
#
@Chats ||= {}
@Chats.cable = ActionCable.createConsumer()
@Chats.forum = ''
@Chats.privt = ''