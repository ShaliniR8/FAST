class AddStartDateEndDateToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :start_date, :date
    add_column :issues, :end_date, :date
  end

  def self.down
    remove_column :issues, :start_date
    remove_column :issues, :end_date
  end
end
