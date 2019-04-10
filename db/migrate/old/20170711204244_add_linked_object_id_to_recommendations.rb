class AddLinkedObjectIdToRecommendations < ActiveRecord::Migration
  def self.up
    add_column :recommendations, :linked_object_id, :integer
  end

  def self.down
    remove_column :recommendations, :linked_object_id
  end
end
