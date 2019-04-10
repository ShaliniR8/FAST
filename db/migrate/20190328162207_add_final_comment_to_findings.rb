class AddFinalCommentToFindings < ActiveRecord::Migration
  def self.up
    add_column :findings, :final_comment, :text
  end

  def self.down
    remove_column :findings, :final_comment
  end
end
