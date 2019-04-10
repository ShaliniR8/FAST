class AddFieldsToSmsActions < ActiveRecord::Migration
  def self.up
    add_column :sms_actions, :user_poc_id, :integer
    add_column :sms_actions, :approver_poc_id, :integer
  end

  def self.down
    remove_column :sms_actions, :approver_poc_id
    remove_column :sms_actions, :user_poc_id
  end
end
