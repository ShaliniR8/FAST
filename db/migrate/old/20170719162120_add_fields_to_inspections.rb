class AddFieldsToInspections < ActiveRecord::Migration
  def self.up
    add_column :inspections, :approver_poc_id, :integer
  end

  def self.down
    remove_column :inspections, :approver_poc_id
  end
end
