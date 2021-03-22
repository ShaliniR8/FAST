class AddIndexToTransactions < ActiveRecord::Migration
  def self.up
    add_index :transactions, [:owner_id, :owner_type]
  end

  def self.down
    remove_index :transactions, [:owner_id, :owner_type]
  end
end
