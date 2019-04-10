class AddViewerAccess < ActiveRecord::Migration
  def self.up
    add_column :investigations,:viewer_access,:boolean,:default=>false
  end

  def self.down
  end
end
