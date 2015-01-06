class AddLockToGames < ActiveRecord::Migration
  def change
    add_column :games, :locked, :boolean, default: :false
  end
end
