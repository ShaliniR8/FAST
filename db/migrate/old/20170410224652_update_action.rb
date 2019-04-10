class UpdateAction < ActiveRecord::Migration
  def self.up
    add_column :sms_actions,:user_id,:integer
  end

  def self.down
	  
  end
end
