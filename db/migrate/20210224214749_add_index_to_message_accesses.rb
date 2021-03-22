class AddIndexToMessageAccesses < ActiveRecord::Migration
  def self.up
    add_index :message_accesses, [:type, :users_id]
  end

  def self.down
    remove_index :message_accesses, [:type, :users_id]
  end
end
