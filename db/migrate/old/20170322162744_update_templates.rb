class UpdateTemplates < ActiveRecord::Migration
  def self.up
    add_column :templates,:emp_group,:string
    add_column :templates,:report_type,:string
  end

  def self.downi
    remove_column :templates,:emp_group
    remove_column :templates,:report_type
  end
end
