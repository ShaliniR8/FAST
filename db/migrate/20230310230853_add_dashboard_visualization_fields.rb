class AddDashboardVisualizationFields < ActiveRecord::Migration
  def self.up
    add_column :query_visualizations, :dashboard_pin, :boolean, :default => false
    add_column :query_visualizations, :dashboard_pin_size, :integer, :default => 12
    add_column :query_visualizations, :dashboard_default_chart, :integer, :default => 1
  end

  def self.down
    remove_column :query_visualizations, :dashboard_pin
    remove_column :query_visualizations, :dashboard_pin_size
    remove_column :query_visualizations, :dashboard_default_chart
  end
end
