Feature: Edit bracket as admin
  In order to enter the teams in the bracket
  As the admin
  I want to enter teams into the bracket and have players see that bracket

  Scenario: Seeing the bracket
    Given 'An admin' who is logged in
    When I click the 'Edit Bracket' link
    Then I should see the initial bracket

  @javascript
  Scenario: Entering the name of a team
    Given 'An admin' visiting the 'Edit Bracket' page
    When I change the name of the team 'Team 61' to 'Colorado'
    Then I should see 'Colorado' on the 'Edit Bracket' page in place of 'Team 61'
    And The team 'Colorado' should be the 'name' for 'Team 61'

  @javascript
  Scenario: Filling out the initial bracket
    Given 'An admin' visiting the 'Edit Bracket' page
    When I change the names of the teams
    Then The teams should have the new names
    And I should see the new names on the 'Edit Bracket' page

