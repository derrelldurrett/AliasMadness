class AddChatNameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :chat_name, :string
  end
end
