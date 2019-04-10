class MoreComments < ActiveRecord::Migration
  def self.up
    add_column :sras,:reviewer_comment,:text
    add_column :sras,:approver_comment,:text
  end

  def self.down
  end
end
