class AddColumnsToFields < ActiveRecord::Migration
  def self.up
    add_column :fields, :nested_field_id, :integer
    add_column :fields, :nested_field_value, :string
  end

  def self.down
    remove_column :fields, :nested_field_id
    remove_column :fields, :nested_field_value
  end
end
