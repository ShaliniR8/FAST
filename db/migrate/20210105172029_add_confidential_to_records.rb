class AddConfidentialToRecords < ActiveRecord::Migration
  def self.up
    add_column :records, :confidential, :boolean, default: false
  end

  def self.down
    remove_column :records, :confidential
  end
end
