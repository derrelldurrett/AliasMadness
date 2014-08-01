# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
nameTeam = (target) ->
  send_put(t) for t in $(target)

send_put = (target) ->
  # send the new team name to the server
  # confirm that the change succeeded?
  # update the object in memory?
  newName = target.value
  node=$(target).closest('td').data('node')
#  console.log "giving node #{node} a new name: #{newName}"
  $.ajax
    type: 'PUT'
    url: $(target).closest('form').attr('action')
    data:
      'team[name]': newName
      'bracket[node]': node

$ ->
  $('input#bracket_teams_attributes_name').on 'change', (e) => nameTeam e.target

