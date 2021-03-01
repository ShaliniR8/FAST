class AddIndexToRecordFields < ActiveRecord::Migration
  def self.up
    add_index :record_fields, :records_id
    add_index :submission_fields, :submissions_id
  end

  def self.down
    remove_index :record_fields, :records_id
    remove_index :submission_fields, :submissions_id
  end
end
