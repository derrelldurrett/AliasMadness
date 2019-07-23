Feature: Heckle forum behavior
  In order to create more camaraderie among players
  As a Player
  I want to be able to send and receive messages to my fellow players
  and receive messages from the Admin

  @javascript
  Scenario: A user who is logged in can show/hide the chat window
    Given 'An invited player' logs in with all teams entered
    When I click 'Show heckles'
