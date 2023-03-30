class RemoveGridValuesFlatListToQueryVisualization < ActiveRecord::Migration
  def self.up
    remove_column :query_visualizations, :grid_values_flat_list
  end

  def self.down
    add_column :query_visualizations, :grid_values_flat_list, :string
  end
end
