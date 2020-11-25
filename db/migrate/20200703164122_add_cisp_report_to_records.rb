class AddCispReportToRecords < ActiveRecord::Migration
  def self.up
    add_column :records, :cisp_ready, :boolean, default: false
    add_column :records, :cisp_sent, :boolean, default: false
  end

  def self.down
    remove_column :records, :cisp_ready
    remove_column :records, :cisp_sent
  end
end
