class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.integer :seed
      t.integer :label

      t.timestamps
    end
  end
end
