class AddObjectIdToFindings < ActiveRecord::Migration
  def self.up
    add_column :findings, :object_id, :integer
  end

  def self.down
    remove_column :findings, :object_id
  end
end
