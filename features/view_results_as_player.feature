Feature: View results as player
  In order to know where I stand in the pool
  As a player
  I want to see the winning and losing choices I've made
  And I want to see the pool's standings

  @javascript @wip
  Scenario: Seeing the bracket in progress
    Given 'An invited player' visiting the 'Edit Bracket' page with all player's games entered
    When The Admin has updated some games the first time
    And I view my bracket
    Then 'An invited player' should see the correct choices in green and the incorrect choices in red the first time
    And the 'Edit Bracket' page should reflect the first standings
