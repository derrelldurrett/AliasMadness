When %q(The Admin enters a subject and message into the appropriate fields) do
  fill_in 'Subject', with: 'some subject'
  fill_in 'Message', with: 'this is my test message'
end

Then %q(The players should be sent the message) do
  get_players.each do |p|
    expect(mailbox_for(p.email).size).to eq parse_email_count(1)
  end
end
