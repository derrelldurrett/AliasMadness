Feature: Players want to heckle each other for their failures and successes
  In order to heckle each other mercilessly
  As a player
  I want a chat window into which I can type either group or individual messages

  @javascript
  Scenario: I want to type a group message into the chat window, and have
  other players see it
    Given 'An invited player' logs in with all teams entered and other players invited
    When I type in the chat window
    Then I see my heckle in the response window

  @wip
  @javascript
  Scenario: I want to receive messages sent to the group
    Given 'An invited player' logs in with all teams entered and other players invited
    When Another player sends a heckkle
    Then I should see the heckle in my response window
