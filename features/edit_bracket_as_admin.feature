Feature: Edit bracket
  In order to enter the teams in the bracket
  As the admin
  I want to enter teams into the bracket and have players see that bracket

  Scenario: Adding teams to the bracket
    Given An admin who is logged in
    When I click the 'Edit bracket' link
    Then I should see the initial bracket
