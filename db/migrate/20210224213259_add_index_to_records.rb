class AddIndexToRecords < ActiveRecord::Migration
  def self.up
    add_index :records, :templates_id
    add_index :records, :viewer_access
    add_index :records, :reports_id
    add_index :records, :status
  end

  def self.down
    remove_index :records, :templates_id
    remove_index :records, :viewer_access
    remove_index :records, :reports_id
    remove_index :records, :status
  end
end
