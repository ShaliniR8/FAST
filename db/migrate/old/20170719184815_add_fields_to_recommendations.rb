class AddFieldsToRecommendations < ActiveRecord::Migration
  def self.up
    add_column :recommendations, :user_poc_id, :integer
  end

  def self.down
    remove_column :recommendations, :user_poc_id
  end
end
