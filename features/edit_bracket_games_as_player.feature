Feature: Edit bracket as player
  In order to enter the winners in my bracket
  As an invited player
  I want to see the bracket
  and be able to enter my games
  and have them count

  @javascript
  Scenario: Choosing winners for games
    Given 'An invited player' logs in with all teams entered
    When An invited player enters the winners for the games
    Then The games should display correctly
    And The database should reflect the game choices

  @javascript
  Scenario: I should not be able to change the names of the teams
    Given 'An invited player' logs in with all teams entered
    When I view "my bracket"
    Then I should not be able to change 'Colorado' to 'CSU-Pueblo'

  @javascript
  Scenario: When I change a game and have chosen subsequent games, the subsequent games should be reset
    Given 'An invited player' logs in with all teams entered and players' games chosen
    When I change a game's winner
    Then The subsequent games should display 'Choose winner...'

  @javascript
  Scenario: I should not be able to edit another user's bracket.
    Given 'An invited player' logs in with all teams entered and other players invited
    When I view "another player's bracket"
    Then I should not be able to change its games