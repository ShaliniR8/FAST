class AddCorrectiveActionsCommentToCorrectiveActions < ActiveRecord::Migration
  def self.up
    add_column :corrective_actions, :corrective_actions_comment, :text
  end

  def self.down
    remove_column :corrective_actions, :corrective_actions_comment
  end
end
