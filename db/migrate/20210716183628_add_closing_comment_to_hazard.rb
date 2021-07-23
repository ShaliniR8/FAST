class AddClosingCommentToHazard < ActiveRecord::Migration
  def self.up
    add_column :hazards, :closing_comment, :text
  end

  def self.down
    remove_column :hazards, :closing_comment
  end
end
