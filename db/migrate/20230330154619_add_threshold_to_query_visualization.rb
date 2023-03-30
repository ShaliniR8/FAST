class AddThresholdToQueryVisualization < ActiveRecord::Migration
  def self.up
    add_column :query_visualizations, :threshold, :integer
  end

  def self.down
    remove_column :query_visualizations, :threshold
  end
end
