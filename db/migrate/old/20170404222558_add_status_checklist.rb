class AddStatusChecklist < ActiveRecord::Migration
  def self.up
    add_column :checklist_items,:status,:string,:default=>"New"
    add_column :checklist_items,:compliance,:string
  end


  def self.down
  end
end
