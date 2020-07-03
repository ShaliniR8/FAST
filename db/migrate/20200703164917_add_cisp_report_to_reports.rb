class AddCispReportToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :cisp_ready, :boolean, default: false
  end

  def self.down
    remove_column :reports, :cisp_ready
  end
end
