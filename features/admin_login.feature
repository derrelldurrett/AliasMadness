Feature: Admin login
  In order to start the pool
  As the Admin
  I want to visit a specific URL based on my email address
  and enter my password
  and login
  and have the correct time-based options presented to me: to enter players, until the deadline is reached, to enter teams into the bracket once it's announced,

  Scenario: Visiting the login page with a valid email address
    Given The database is seeded
    And The Admin's email address
    And a link to the login page with the email as the parameter
    And an existing database seeded with the Admin's data
    When I visit the 'login' page
    Then the page should contain the email address in the 'email' field
    And the 'password' field should be empty

  Scenario: Entering the password and clicking 'Login' logs in the Admin
    Given The database is seeded
    And The Admin's email address and password
    And a link to the login page containing the email
    When I visit the login page, enter the password, and click 'Login'
    Then I should have a choice between creating Players, creating Brackets, choosing winners for games, or sending a message about the state of the pool, depending on the time at which I visit the page.

  Scenario: Visiting the login page with an invalid/missing email address
    Given The database is seeded
    And an invalid or missing email address
    And a link to the login page containing the email
    And an existing database seeded with the Admin's data
    When I visit the 'login' page
    Then the returned page should be ‘404’

