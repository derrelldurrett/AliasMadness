Feature: Players want to see who will win the pool for a given set of results
  In order to create drama about the remainder of the pool after most brackets are busted
  As a player
  I want to see whose bracket performs best when a particular set of results occur

  #@wip
  Scenario: Admin has entered winning teams for at least some games
    Given The pool is in progress with a specific set of players and teams
    When I view scenarios
    Then I should see Round 4 in two Scenarios and Round 4 and Round 5 in eight Scenarios
    And I should see Team 8 in exactly two Round 4 Scenarios