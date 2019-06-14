class ChangeColumnTypeOfChecklistCell < ActiveRecord::Migration
  def self.up
    change_column :checklist_cells, :value, :text
  end

  def self.down
    change_column :checklist_cells, :value, :string
  end
end
