class AddEmployeeGroupToFaaReports < ActiveRecord::Migration
  def self.up
    add_column :faa_reports, :employee_group, :string
  end

  def self.down
    remove_column :faa_reports, :employee_group
  end
end
