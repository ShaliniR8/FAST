class AddCloseDateToSafetyReportingModule < ActiveRecord::Migration
  def self.up
    add_column :records, :close_date, :date
    add_column :reports, :close_date, :date
    add_column :corrective_actions, :close_date, :date
  end

  def self.down
    remove_column :records, :close_date
    remove_column :reports, :close_date
    remove_column :corrective_actions, :close_date
  end
end
