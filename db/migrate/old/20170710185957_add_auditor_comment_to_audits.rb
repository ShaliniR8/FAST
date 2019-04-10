class AddAuditorCommentToAudits < ActiveRecord::Migration
  def self.up
    add_column :audits, :auditor_comment, :text
  end

  def self.down
    remove_column :audits, :auditor_comment
  end
end
