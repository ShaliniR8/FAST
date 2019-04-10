class AddViewerAccess < ActiveRecord::Migration
  def self.up
    add_column :records,:viewer_access,:boolean,default: false
    add_column :access_controls,:viewer_access,:boolean
  end

  def self.down
    remove_column :records,:viewer_access
    remove_column :access_controls,:viewer_access
  end
end
