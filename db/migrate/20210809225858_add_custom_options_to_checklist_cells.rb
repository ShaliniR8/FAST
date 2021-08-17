class AddCustomOptionsToChecklistCells < ActiveRecord::Migration
  def self.up
    add_column :checklist_cells, :custom_options, :text
  end

  def self.down
    remove_column :checklist_cells, :custom_options
  end
end
