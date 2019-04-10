class MoreRiskControl < ActiveRecord::Migration
  def self.up
    add_column :risk_controls,:approver_comment,:text
    add_column :risk_controls,:follow_up,:text
    add_column :risk_controls,:notes,:text
    add_column :risk_controls,:action_implemented,:boolean
  end

  def self.down
  end
end
