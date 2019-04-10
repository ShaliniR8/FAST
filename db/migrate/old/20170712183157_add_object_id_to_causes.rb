class AddObjectIdToCauses < ActiveRecord::Migration
  def self.up
    add_column :causes, :object_id, :integer
  end

  def self.down
    remove_column :causes, :object_id
  end
end
