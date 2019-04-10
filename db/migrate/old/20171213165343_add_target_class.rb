class AddTargetClass < ActiveRecord::Migration
  def self.up
    add_column :query_statements,:target_class,:string
  end

  def self.down
  end
end
