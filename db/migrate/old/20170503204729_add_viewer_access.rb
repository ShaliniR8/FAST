class AddViewerAccess < ActiveRecord::Migration
  def self.up
    add_column :audits,:viewer_access,:boolean,:default=>false
  end

  def self.down
    remove_column :audits,:viewer_access
  end
end
