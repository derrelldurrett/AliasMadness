class RemoveCurrentScoreFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :current_score
    add_column :brackets, :current_score, :integer, default: 0
  end

  def down
    remove_column :brackets, :current_score
    add_column :users, :current_score, :integer
  end
end
