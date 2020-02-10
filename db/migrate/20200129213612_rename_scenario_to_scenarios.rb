class RenameScenarioToScenarios < ActiveRecord::Migration[5.2]
  def change
    rename_table :scenario, :scenarios
  end
end
