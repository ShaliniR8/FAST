class AddViewerAccessToSra < ActiveRecord::Migration
  def self.up
    add_column :sras, :viewer_access, :boolean, :default => false
  end

  def self.down
    remove_column :sras, :viewer_access
  end
end
