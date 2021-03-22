class AddMaxOptionsToFields < ActiveRecord::Migration
  def self.up
    add_column :fields, :max_options, :integer, default: 1
  end

  def self.down
    remove_column :fields, :max_options
  end
end
