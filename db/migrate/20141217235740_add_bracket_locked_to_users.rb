class AddBracketLockedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bracket_locked, :boolean, default: :false
  end
end
