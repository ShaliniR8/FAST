class AddSpawnIdToEvaluations < ActiveRecord::Migration
  def self.up
    add_column :evaluations, :spawn_id, :integer, :default => 0
    change_column :evaluations, :spawn_id, :integer, :default => 0
  end
  def self.down
    remove_column :evaluations, :spawn_id
  end
end
