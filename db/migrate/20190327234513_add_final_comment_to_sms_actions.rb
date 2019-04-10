class AddFinalCommentToSmsActions < ActiveRecord::Migration
  def self.up
    add_column :sms_actions, :final_comment, :text
  end

  def self.down
    remove_column :sms_actions, :final_comment
  end
end
