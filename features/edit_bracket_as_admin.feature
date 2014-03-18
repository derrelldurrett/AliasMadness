Feature: Edit bracket
  In order to enter the teams in the bracket
  As the admin
  I want to enter teams into the bracket and have players see that bracket

  Scenario: Seeing the bracket
    Given An admin who is logged in
    When I click the 'Edit Bracket' link
    Then I should see the initial bracket

  @webkit
  Scenario: Filling out the initial bracket
    Given An admin who is logged in
    And I am visiting the 'Edit Bracket' page
    When I change 'Team 1' to 'Colorado' and hit return
    Then I should see 'Colorado' on the 'Edit Bracket' page
#    And The team 'Colorado' should be the 'name' for 'Team 1'
#    And '8' should be the 'seed' for
