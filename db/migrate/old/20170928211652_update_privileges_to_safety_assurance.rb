class UpdatePrivilegesToSafetyAssurance < ActiveRecord::Migration
  def self.up
    add_column :audits,:privileges,:text   
    add_column :investigations,:privileges,:text
    add_column :inspections,:privileges,:text
    add_column :evaluations,:privileges,:text
    add_column :findings,:privileges,:text
    add_column :sms_actions,:privileges,:text
    add_column :recommendations,:privileges,:text
  end

  def self.down
  end
end
