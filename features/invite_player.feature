Feature: Invite player
  In order to have people play in the pool
  As the Admin
  I want to be able to invite Players
  by entering their email address
  and have the app send them a message with the details.

  Scenario: Inviting Players
    Given The database is seeded
    And 'An admin' who is logged in
    And I am visiting the 'Invite Player' page
    When A Player does not exist and I enter a his data
    Then I should have a new player in the database
    And I should see a message that my Player was created
    And I should see the page to invite a new Player
    And I should send an email to the Player with a link for the Player to log in

  Scenario: Inviting Players
    Given The database is seeded
    And 'An admin' who is logged in
    And I am visiting the 'Invite Player' page
    And A player with name 'derrell' and email 'dd@fake.com' already exists
    When I invite an existing player
    Then I should see the "Player 'derrell' not invited" error
