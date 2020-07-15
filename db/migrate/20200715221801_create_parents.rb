class CreateParents < ActiveRecord::Migration
  def self.up
    create_table :parents do |t|
      t.string  "parent_type"
      t.integer "parent_id"
      t.string  "owner_type"
      t.integer "owner_id"
      t.timestamps
    end
  end

  def self.down
    drop_table :parents
  end
end
