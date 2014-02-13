class RemoveEmailModel < ActiveRecord::Migration
  def up
    drop_table :emails
    remove_column :users, :email_id
    add_column :users, 'email', :string
  end

  def down
    remove_column :users, :email
    create_table :emails do |t|
      t.string :value
      t.belongs_to :email

      t.timestamps
    end
    add_index :users, :email_id
  end
end
