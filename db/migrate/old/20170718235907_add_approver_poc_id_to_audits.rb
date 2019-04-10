class AddApproverPocIdToAudits < ActiveRecord::Migration
  def self.up
    add_column :audits, :approver_poc_id, :integer
  end

  def self.down
    remove_column :audits, :approver_poc_id
  end
end
