class AddCurrentScoreToUser < ActiveRecord::Migration
  def change
    add_column :users, :current_score, :integer, default: 0
  end
end
