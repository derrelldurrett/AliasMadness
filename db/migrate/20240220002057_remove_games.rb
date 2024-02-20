class RemoveGames < ActiveRecord::Migration[7.0]
  def change
    drop_table :games
  end
end
