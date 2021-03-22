class ChangeSmsActionCommentsStringToText < ActiveRecord::Migration
  def self.up
    change_column :sms_actions, :immediate_action_comment, :text
    change_column :sms_actions, :comprehensive_action_comment, :text
  end

  def self.down
    change_column :sms_actions, :immediate_action_comment, :string
    change_column :sms_actions, :comprehensive_action_comment, :string
  end
end
