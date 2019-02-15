class AddEliminatedToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :eliminated, :boolean, default: :false
  end
end
