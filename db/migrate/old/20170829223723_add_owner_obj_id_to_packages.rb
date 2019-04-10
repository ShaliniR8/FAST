class AddOwnerObjIdToPackages < ActiveRecord::Migration
  def self.up
    add_column :packages, :owner_obj_id, :integer
  end

  def self.down
    remove_column :packages, :owner_obj_id
  end
end
