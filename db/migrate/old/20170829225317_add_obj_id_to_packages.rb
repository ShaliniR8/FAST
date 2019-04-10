class AddObjIdToPackages < ActiveRecord::Migration
  def self.up
    add_column :packages, :obj_id, :integer
  end

  def self.down
    remove_column :packages, :obj_id
  end
end
