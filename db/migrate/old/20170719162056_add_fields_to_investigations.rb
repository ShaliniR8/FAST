class AddFieldsToInvestigations < ActiveRecord::Migration
  def self.up
    add_column :investigations, :approver_poc_id, :integer
    add_column :investigations, :investigator_poc_id, :integer
  end

  def self.down
    remove_column :investigations, :investigator_poc_id
    remove_column :investigations, :approver_poc_id
  end
end
