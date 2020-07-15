class CreateChildren < ActiveRecord::Migration
  def self.up
    create_table :children do |t|
      t.string  "child_type"
      t.integer "child_id"
      t.string  "owner_type"
      t.integer "owner_id"
      t.timestamps
    end
  end

  def self.down
    drop_table :children
  end
end
