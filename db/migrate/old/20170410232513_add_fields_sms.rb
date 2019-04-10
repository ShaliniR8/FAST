class AddFieldsSms < ActiveRecord::Migration
  def self.up
    add_column :sms_actions , :emp,:boolean,:default=>false
    add_column :sms_actions,  :dep,:boolean,:default=>false

  end

  def self.down
  end
end
