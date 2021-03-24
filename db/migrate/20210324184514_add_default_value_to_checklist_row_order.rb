class AddDefaultValueToChecklistRowOrder < ActiveRecord::Migration
  def self.up
    change_column :checklist_rows, :row_order, :integer, :default => 1000
  end

  def self.down
  end
end
