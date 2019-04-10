class AddFinalCommentToCorrectiveActions < ActiveRecord::Migration
  def self.up
    add_column :corrective_actions, :final_comment, :text
  end

  def self.down
    remove_column :corrective_actions, :final_comment
  end
end
