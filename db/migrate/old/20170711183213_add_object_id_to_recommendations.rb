class AddObjectIdToRecommendations < ActiveRecord::Migration
  def self.up
    add_column :recommendations, :object_id, :integer
  end

  def self.down
    remove_column :recommendations, :object_id
  end
end
