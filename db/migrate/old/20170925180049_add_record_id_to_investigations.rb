class AddRecordIdToInvestigations < ActiveRecord::Migration
  def self.up
    add_column :investigations, :record_id, :int
  end

  def self.down
    remove_column :investigations, :record_id
  end
end
