class AddFieldOrderToFields < ActiveRecord::Migration
  def self.up
    add_column :fields, :field_order, :integer
  end

  def self.down
    remove_column :fields, :field_order
  end
end
