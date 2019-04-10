class AddStatusDefault < ActiveRecord::Migration
  def self.up
    change_column :sms_actions,:status,:string,:default=>"New"
  end

  def self.down
  end
end
