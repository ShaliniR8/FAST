class AddViewTypeToChecklists < ActiveRecord::Migration
  def self.up
    add_column :checklists, :table_view, :boolean, default: true
  end

  def self.down
    remove_column :checklists, :table_view
  end
end
