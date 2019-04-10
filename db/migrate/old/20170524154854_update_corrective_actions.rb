class UpdateCorrectiveActions < ActiveRecord::Migration
  def self.up
    add_column :sms_actions,:type,:string
  end

  def self.down
  end
end
