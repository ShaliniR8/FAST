class AddIndexToRecords < ActiveRecord::Migration
  def self.up
    add_index :records, :templates_id
    add_index :records, :viewer_access
  end

  def self.down
    remove_index :records, :templates_id
    remove_index :records, :viewer_access
  end
end
