class AddSpawnIdToAudits < ActiveRecord::Migration
  def self.up
    add_column :audits, :spawn_id, :integer, :default => 0
    change_column :audits, :spawn_id, :integer, :default => 0
  end
  def self.down
    remove_column :audits, :spawn_id
  end
end
