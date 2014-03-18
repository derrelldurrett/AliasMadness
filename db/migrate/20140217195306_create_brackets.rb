class CreateBrackets < ActiveRecord::Migration
  def change
    create_table :brackets do |t|
      t.belongs_to :user
      t.text :bracket_data
      t.text :lookup_by_label

      t.timestamps
    end
  end
end
