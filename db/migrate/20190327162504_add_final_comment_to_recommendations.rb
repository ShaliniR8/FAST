class AddFinalCommentToRecommendations < ActiveRecord::Migration
  def self.up
    add_column :recommendations, :final_comment, :text
  end

  def self.down
    remove_column :recommendations, :final_comment
  end
end
