class AddFinalCommentToInspections < ActiveRecord::Migration
  def self.up
    add_column :inspections, :final_comment, :text
  end

  def self.down
    remove_column :inspections, :final_comment
  end
end
