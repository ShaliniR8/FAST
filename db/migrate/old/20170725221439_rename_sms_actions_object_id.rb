class RenameSmsActionsObjectId < ActiveRecord::Migration
  def self.up
    rename_column :sms_actions, :object_id, :obj_id
  end

  def self.down
  end
end
