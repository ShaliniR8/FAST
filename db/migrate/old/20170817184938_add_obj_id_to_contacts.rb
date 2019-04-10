class AddObjIdToContacts < ActiveRecord::Migration
  def self.up
    add_column :contacts, :obj_id, :integer
  end

  def self.down
    remove_column :contacts, :obj_id
  end
end
