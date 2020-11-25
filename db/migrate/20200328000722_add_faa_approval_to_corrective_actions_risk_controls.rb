class AddFaaApprovalToCorrectiveActionsRiskControls < ActiveRecord::Migration
  def self.up
    add_column :corrective_actions, :faa_approval, :boolean, default: false
    add_column :sms_actions, :faa_approval, :boolean, default: false
    add_column :risk_controls, :faa_approval, :boolean, default: false
  end

  def self.down
    remove_column :corrective_actions, :faa_approval
    remove_column :sms_actions, :faa_approval
    remove_column :risk_controls, :faa_approval
  end
end
