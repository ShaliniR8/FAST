class AddFinalCommentToRiskControls < ActiveRecord::Migration
  def self.up
    add_column :risk_controls, :final_comment, :text
  end

  def self.down
    remove_column :risk_controls, :final_comment
  end
end
