class AddLockToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :locked, :boolean, default: :false
  end
end
