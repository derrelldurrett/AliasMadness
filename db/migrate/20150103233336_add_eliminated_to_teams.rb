class AddEliminatedToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :eliminated, :boolean, default: :false
  end
end
