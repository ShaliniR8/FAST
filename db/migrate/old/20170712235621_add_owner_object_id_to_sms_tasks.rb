class AddOwnerObjectIdToSmsTasks < ActiveRecord::Migration
  def self.up
    add_column :sms_tasks, :owner_object_id, :integer
  end

  def self.down
    remove_column :sms_tasks, :owner_object_id
  end
end
