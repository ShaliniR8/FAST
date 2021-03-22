class AddRowOrderToChecklistRow < ActiveRecord::Migration
  def self.up
    add_column :checklist_rows, :row_order, :integer
  end

  def self.down
    remove_column :checklist_rows, :row_order
  end
end
