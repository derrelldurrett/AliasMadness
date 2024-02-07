group_chat_text = 'this is a chat to the group'.freeze
When("I type in the chat window") do
  # fill_in doesn't work with contenteditable divs....
  find('#chat-text').set(group_chat_text)
  find('#chat-text').native.send_keys(:return)
  sleep 2
end

Then('I see my heckle in the response window') do
  expect(find('div#chats-received')).to have_text(group_chat_text)
end

Then 'I should see my chat name in the response' do
  expect(find('div#chats-received')).to have_text('@'+logged_in_player.chat_name)
end

group_chat_text2 = 'this is my heckle'.freeze
sender = nil
When 'Another player sends a heckle' do
  sender = choose_another_player
  Heckle.create! content: group_chat_text2, from_id: sender.id
  sleep 5
end

Then 'I should see the heckle in my response window' do
  expect(find('div#chats-received')).to have_text(group_chat_text2)
end

Then 'I should see their chat name in the response' do
  expect(find('div#chats-received')).to have_text('@'+sender.chat_name)
end

private_heckle = 'this is a private message to'.freeze
When "I use the '@' sign to identify another user by first name, and send them a heckle" do
  find('#chat-text').set(private_heckle + ' @' + choose_another_player.chat_name)
  find('#chat-text').send_keys(:return)
  find('#chat-text').send_keys(:return)
  sleep 20
end

Then 'I should see the private heckle in my response window' do
  expect(find('div#chats-received')).to have_text(private_heckle)
end
