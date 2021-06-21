class AddSpawnIdToInspections < ActiveRecord::Migration
  def self.up
    add_column :inspections, :spawn_id, :integer, :default => 0
    change_column :inspections, :spawn_id, :integer, :default => 0
  end
  def self.down
    remove_column :inspections, :spawn_id
  end
end
