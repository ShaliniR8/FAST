class AddSabreMapFieldToFields < ActiveRecord::Migration
  def self.up
    add_column :fields, :sabre_map, :string
  end

  def self.down
    remove_column :fields, :sabre_map
  end
end
