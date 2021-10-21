class AddAsrsSentToRecords < ActiveRecord::Migration
  def self.up
    add_column :records, :asrs_sent, :boolean
  end

  def self.down
    remove_column :records, :asrs_sent
  end
end
