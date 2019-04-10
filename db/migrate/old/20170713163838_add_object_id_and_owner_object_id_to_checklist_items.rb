class AddObjectIdAndOwnerObjectIdToChecklistItems < ActiveRecord::Migration
  def self.up
    add_column :checklist_items, :obj_id, :integer
    add_column :checklist_items, :owner_obj_id, :integer
  end

  def self.down
    remove_column :checklist_items, :owner_obj_id
    remove_column :checklist_items, :obj_id
  end
end
