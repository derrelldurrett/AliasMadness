class CreateHeckles < ActiveRecord::Migration[5.2]
  def change
    create_table :heckles do |t|
      t.text :content

      t.timestamps
    end
  end
end
