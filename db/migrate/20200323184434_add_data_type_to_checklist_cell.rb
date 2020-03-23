class AddDataTypeToChecklistCell < ActiveRecord::Migration
  def self.up
    add_column :checklist_cells, :data_type, :string
  end

  def self.down
    remove_column :checklist_cells, :data_type
  end
end
