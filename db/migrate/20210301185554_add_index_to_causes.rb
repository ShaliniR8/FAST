class AddIndexToCauses < ActiveRecord::Migration
  def self.up
    add_index :causes, :owner_id
  end

  def self.down
    remove_index :causes, :owner_id
  end
end
