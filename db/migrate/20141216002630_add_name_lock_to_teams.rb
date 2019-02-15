class AddNameLockToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :name_locked, :boolean, default: :false
  end
end
