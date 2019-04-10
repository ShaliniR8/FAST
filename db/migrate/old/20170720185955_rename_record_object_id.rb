class RenameRecordObjectId < ActiveRecord::Migration
  def self.up
    rename_column :records, :object_id, :user_object_id
  end

  def self.down
    rename_column :records, :user_object_id, :object_id
  end
end
