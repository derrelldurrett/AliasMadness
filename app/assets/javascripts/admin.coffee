#= require brackets

# Admin behavior
$ ->
  bracket = new Bracket()
  $('input.team_name').on 'change', (e) => bracket.nameTeam e.target
  $('button#team_entry_done').on 'click', (e) => bracket.fixTeamNames e
  $('button#lock_players_brackets').on 'click', (e) => bracket.lockPlayersBrackets e
