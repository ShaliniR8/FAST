class AddObjectId < ActiveRecord::Migration
  def self.up
    add_column :submissions,:object_id,:integer
  end

  def self.down
  end
end
