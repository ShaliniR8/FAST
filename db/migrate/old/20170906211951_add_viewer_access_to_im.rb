class AddViewerAccessToIm < ActiveRecord::Migration
  def self.up
    add_column :ims, :viewer_access, :boolean, :default => false
  end

  def self.down
    remove_column :ims, :viewer_access
  end
end
