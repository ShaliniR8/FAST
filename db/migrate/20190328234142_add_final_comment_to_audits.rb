class AddFinalCommentToAudits < ActiveRecord::Migration
  def self.up
    add_column :audits, :final_comment, :text
  end

  def self.down
    remove_column :audits, :final_comment
  end
end
