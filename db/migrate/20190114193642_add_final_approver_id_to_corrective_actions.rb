class AddFinalApproverIdToCorrectiveActions < ActiveRecord::Migration
  def self.up
    add_column :corrective_actions, :final_approver_id, :integer
  end

  def self.down
    remove_column :corrective_actions, :final_approver_id
  end
end
