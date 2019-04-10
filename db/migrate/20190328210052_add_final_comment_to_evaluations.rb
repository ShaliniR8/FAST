class AddFinalCommentToEvaluations < ActiveRecord::Migration
  def self.up
    add_column :evaluations, :final_comment, :text
  end

  def self.down
    remove_column :evaluations, :final_comment
  end
end
