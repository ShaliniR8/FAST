class AddOwnerObjectIdToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :owner_object_id, :integer
  end

  def self.down
    remove_column :transactions, :owner_object_id
  end
end
