Feature: Login always with the same password as player
  In order to always login with the same password
  As a player
  I want to always use the same password to login

  @javascript
  Scenario: Logging in, several times (pretend it takes a while)
    Given 'An invited player' should see the bracket in progress
    When The Admin has updated some games the second time
    Then 'An invited player' should see the correct choices in green and the incorrect choices in red the second time
