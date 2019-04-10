class UpdateModules < ActiveRecord::Migration
  def self.up
    add_column :sms_tasks,:type,:string
    rename_column :sms_tasks,:im_id,:owner_id
    add_column :contacts,:type,:string
    rename_column :contacts,:im_id,:owner_id
  end

  def self.down
  end
end
