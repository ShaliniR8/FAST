class AddClosingCommentToRiskControl < ActiveRecord::Migration
  def self.up
    add_column :risk_controls, :closing_comment, :text
  end

  def self.down
    remove_column :risk_controls, :closing_comment
  end
end
