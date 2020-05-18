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
    And I should see my chat name in the response

  @javascript
  Scenario: I want to receive messages sent to the group
    Given 'An invited player' logs in with all teams entered and other players invited
    When Another player sends a heckle
    Then I should see the heckle in my response window
    And I should see their chat name in the response

  @wip
  @javascript
  Scenario: I want to send messages to a specific other user (and see them reflected in my chats)
    Given 'An invited player' logs in with all teams entered and other players invited
    When I use the '@' sign to identify another user by first name, and send them a heckle
    Then I should see the private heckle in my response window
