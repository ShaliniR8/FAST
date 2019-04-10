class AddFinalCommentToInvestigations < ActiveRecord::Migration
  def self.up
    add_column :investigations, :final_comment, :text
  end

  def self.down
    remove_column :investigations, :final_comment
  end
end
