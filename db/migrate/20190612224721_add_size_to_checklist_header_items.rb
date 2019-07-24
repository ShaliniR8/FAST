class AddSizeToChecklistHeaderItems < ActiveRecord::Migration
  def self.up
    add_column :checklist_header_items, :size, :integer
  end

  def self.down
    remove_column :checklist_header_items, :size
  end
end
