Feature: View results as player
  In order to know where I stand in the pool
  As a player
  I want to see the winning and losing choices I've made
  And I want to see the pool's standings

  Scenario: Seeing the bracket in progress
    Given 'An invited player' visiting the 'Edit Bracket' page with all player's games entered
    When An admin updates the bracket
    And I view my bracket
    Then 'An invited player' should see the correct choices in green and the incorrect choices in red
    