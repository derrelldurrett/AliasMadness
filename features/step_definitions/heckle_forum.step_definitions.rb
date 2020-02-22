group_chat_text = 'this is a chat to the group'.freeze
When("I type in the chat window") do
  fill_in 'chat-text', with: (group_chat_text)
  find('#chat-text').native.send_keys(:return)
  sleep 2
end

Then('I see my heckle in the response window') do
  expect(find('div#chats-received')).to have_text(group_chat_text)
end

group_chat_text2 = 'this is my heckle'.freeze
When 'Another player sends a heckkle' do
  Heckle.create! content: group_chat_text2
  sleep 2
end

Then 'I should see the heckle in my response window' do
  expect(find('div#chats-received')).to have_text(group_chat_text2)
end
