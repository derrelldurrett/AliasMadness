class AddNameLockToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :name_locked, :boolean, default: :false
  end
end
