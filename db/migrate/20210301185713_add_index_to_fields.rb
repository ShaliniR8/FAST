class AddIndexToFields < ActiveRecord::Migration
  def self.up
    add_index :fields, [:deleted, :nested_field_id]
  end

  def self.down
    remove_index :fields, [:deleted, :nested_field_id]
  end
end
