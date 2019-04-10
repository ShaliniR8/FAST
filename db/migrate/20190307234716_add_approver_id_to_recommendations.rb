class AddApproverIdToRecommendations < ActiveRecord::Migration
  def self.up
    add_column :recommendations, :approver_id, :integer
  end

  def self.down
  	remove_column :recommendations, :approver_id
  end
end
