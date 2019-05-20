class AddFinalCommentToRecordsAndMeetings < ActiveRecord::Migration
  def self.up
    add_column :meetings, :final_comment, :text
    add_column :records, :final_comment, :text
  end

  def self.down
    remove_column :meetings, :final_comment
    remove_column :records, :final_comment
  end
end
