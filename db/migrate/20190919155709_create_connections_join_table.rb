class CreateConnectionsJoinTable < ActiveRecord::Migration
  def self.up
    create_table :connections do |t|
      t.integer :owner_id, null: false
      t.string :owner_type, null: false
      t.integer :child_id, null: false
      t.string :child_type, null: false
      t.boolean :complete, null: false, default: false
      t.boolean :archive, null: false, default: false
    end
  end

  def self.down
    drop_table :connections
  end
end
