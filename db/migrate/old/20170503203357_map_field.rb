class MapField < ActiveRecord::Migration
  def self.up
    add_column :fields,:convert_id,:integer
  end

  def self.down
    remove_column :fields,:convert_id
  end
end
