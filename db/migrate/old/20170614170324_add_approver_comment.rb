class AddApproverComment < ActiveRecord::Migration
  def self.up
    add_column :sms_actions,:comment,:text
  end

  def self.down
  end
end
