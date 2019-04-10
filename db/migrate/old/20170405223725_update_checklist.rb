class UpdateChecklist < ActiveRecord::Migration
  def self.up
    add_column :checklist_items,:comment,:text
  end

  def self.down

  end
end
