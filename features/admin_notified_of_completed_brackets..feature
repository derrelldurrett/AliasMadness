Feature: Admin is notified of completed brackets
  In order to know which players have not yet completed their brackets
  As an admin
  I want to see the player's box in the leader board change color when their bracket is complete

  @javascript @wip
  Scenario: Admin has entered the teams, and the players have begun to enter their choices
    Given The database is seeded
    And The players have been invited
    And The teams have already been entered
    When An invited player's winners for the games have all been entered
    Then An admin should see the player's entry in the leader board turn green
