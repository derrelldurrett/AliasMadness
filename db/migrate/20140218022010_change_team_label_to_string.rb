class ChangeTeamLabelToString < ActiveRecord::Migration
  def up
    change_column :teams, :label, :string
  end

  def down
    change_column :teams, :label, :integer
  end
end
