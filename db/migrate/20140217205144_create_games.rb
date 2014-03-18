class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.belongs_to :team
      t.belongs_to :bracket
      t.string :label

      t.timestamps
    end
    add_index :games, :team_id
    add_index :games, :bracket_id
  end
end
