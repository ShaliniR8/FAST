class CreateVisualizationsTable < ActiveRecord::Migration
  def self.up
    create_table :query_visualizations do |t|
      t.timestamps
      t.integer :owner_id
      t.string :x_axis
      t.integer :x_axis_unit
      t.string :series
      t.integer :series_unit
      t.integer :default_chart, :default => 1
    end
  end

  def self.down
    drop_table :query_visualizations
  end
end
