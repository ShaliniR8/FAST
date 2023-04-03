class AddOshaMapToFields < ActiveRecord::Migration
  def self.up
    add_column :fields, :osha_map, :string
  end

  def self.down
    remove_column :fields, :osha_map
  end
end
