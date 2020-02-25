class AddChatIdsToHeckle < ActiveRecord::Migration[5.2]
  def change
    add_column :heckles, :from_id, :integer
    add_column :heckles, :to_id, :integer
  end
end
