class UpdateActions < ActiveRecord::Migration
  def self.up
    change_column :sms_actions,:dep,:boolean,:default=>nil
    change_column :sms_actions,:emp,:boolean,:default=>nil 
  end

  def self.down
   
  end
end
