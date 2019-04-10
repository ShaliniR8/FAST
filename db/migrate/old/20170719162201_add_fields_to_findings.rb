class AddFieldsToFindings < ActiveRecord::Migration
  def self.up
    add_column :findings, :responsible_user_poc_id, :integer
    add_column :findings, :approver_poc_id, :integer
  end

  def self.down
    remove_column :findings, :approver_poc_id
    remove_column :findings, :responsible_user_poc_id
  end
end
