Feature: Edit bracket as player
  In order to enter the winners in my bracket
  As an invited player
  I want to see the bracket
  and be able to enter my games
  and have them count

  @javascript
  Scenario: Choosing winners for games
    Given 'An invited player' visiting the 'Edit Bracket' page with all teams entered
    When An invited player enters the winners for the games
    Then The games should display correctly
    And The database should reflect the game choices

  @javascript
  Scenario: I should not be able to change the names of the teams
    Given 'An invited player' logs in with all teams entered
    When I view my bracket
    Then I should not be able to change 'Colorado' to 'CSU-Pueblo'
