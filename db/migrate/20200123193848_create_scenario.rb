class CreateScenario < ActiveRecord::Migration[5.2]
  def change
    create_table :scenario do |t|
      t.string :scenario_teams
      t.string :result
      t.integer :remaining_games
    end
  end
end
