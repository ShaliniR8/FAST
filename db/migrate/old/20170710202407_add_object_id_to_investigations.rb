class AddObjectIdToInvestigations < ActiveRecord::Migration
  def self.up
    add_column :investigations, :object_id, :integer
  end

  def self.down
    remove_column :investigations, :object_id
  end
end
