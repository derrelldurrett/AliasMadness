Feature: Admin composes messages for players
  In order to communicate the state of play in the pool
  As an admin
  I want to be able to compose and send messages to all players

  Scenario: Admin composes and sends a message to the players
    Given The database is seeded
    And The players have been invited
    And 'An Admin' visiting the 'Send Message' page
    When The Admin enters a subject and message into the appropriate fields
    And Clicks 'Send Message'
    Then The players should be sent the message
