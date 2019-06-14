class AddOptionsToChecklistCells < ActiveRecord::Migration
  def self.up
    add_column :checklist_cells, :options, :text
  end

  def self.down
    remove_column :checklist_cells, :options
  end
end
