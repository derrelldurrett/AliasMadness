class AddCurrentScoreToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :current_score, :integer, default: 0
  end
end
