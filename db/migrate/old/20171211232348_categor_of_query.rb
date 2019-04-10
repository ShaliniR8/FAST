class CategorOfQuery < ActiveRecord::Migration
  def self.up
    add_column :query_conditions,:category_id,:integer
    add_column :query_conditions,:category_name,:string
  end

  def self.down
  end
end
