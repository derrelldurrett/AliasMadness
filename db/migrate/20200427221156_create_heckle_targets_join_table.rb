class CreateHeckleTargetsJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_join_table :heckles, :users do |t|
      t.index [:user_id, :heckle_id], unique: true
    end
  end
end
