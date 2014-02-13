class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.belongs_to :email

      t.timestamps
    end
    add_index :users, :email_id
  end
end
