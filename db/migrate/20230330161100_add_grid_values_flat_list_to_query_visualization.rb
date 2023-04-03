class AddGridValuesFlatListToQueryVisualization < ActiveRecord::Migration
  def self.up
    add_column :query_visualizations, :grid_values_flat_list, :string
  end

  def self.down
    remove_column :query_visualizations, :grid_values_flat_list
  end
end
