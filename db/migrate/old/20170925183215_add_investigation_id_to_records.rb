class AddInvestigationIdToRecords < ActiveRecord::Migration
  def self.up
    add_column :records, :investigation_id, :int
  end

  def self.down
    remove_column :records, :investigation_id
  end
end
