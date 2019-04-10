class AddObjectId < ActiveRecord::Migration
  def self.up
    add_column :submission_fields,:object_id,:integer
  end

  def self.down
  end
end
