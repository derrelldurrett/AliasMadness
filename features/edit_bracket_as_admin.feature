Feature: Edit bracket as admin
  In order to enter the teams in the bracket
  As the admin
  I want to enter teams into the bracket and have players see the results

  Scenario: Seeing the bracket
    Given The database is seeded
    And 'An admin' who is logged in
    When I click the 'Edit Bracket' link
    Then I should see the initial bracket

  @javascript
  Scenario: Entering the name of a team
    Given The database is seeded
    And 'An admin' visiting the 'Edit Bracket' page
    When I change the name of the team 'Team 61' to 'Colorado'
    Then I should see 'Colorado' on the 'Edit Bracket' page in place of 'Team 61', unlocked
    And The team 'Colorado' should be the 'name' for 'Team 61'

  @javascript
  Scenario: Filling out the initial bracket
    Given The database is seeded
    And 'An admin' visiting the 'Edit Bracket' page
    When I change the names of the teams
    And click the button to set the names
    Then The teams should have the new names
    And An admin should see the new names on the 'Edit Bracket' page
    And The team names should not be editable

  @javascript
  Scenario: Choosing the winning teams
    Given 'An admin' visiting the 'Edit Bracket' page with all players' games entered
    When The Admin has updated some games the first time
    Then the invited players scores should be calculated
    And I am visiting 'Edit Bracket'
    And the 'Edit Bracket' page should reflect the first standings

