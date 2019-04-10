class AddObjectIdToSmsActions < ActiveRecord::Migration
  def self.up
    add_column :sms_actions, :object_id, :integer
  end

  def self.down
    remove_column :sms_actions, :object_id
  end
end
