class AddBracketLockedToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :bracket_locked, :boolean, default: :false
  end
end
