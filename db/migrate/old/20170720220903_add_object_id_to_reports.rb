class AddObjectIdToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :object_id, :integer
  end

  def self.down
    remove_column :reports, :object_id
  end
end
