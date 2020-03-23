class AddMaxLengthToFields < ActiveRecord::Migration
  def self.up
    add_column :fields, :max_length, :integer
  end

  def self.down
    remove_column :fields, :max_length
  end
end
