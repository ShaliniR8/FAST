class FullfillSras < ActiveRecord::Migration
  def self.up
    add_column :sras,:reviewer_id,:integer
    add_column :sras,:system_task,:string
    add_column :sras,:compliances,:text
    add_column :sras,:compliances_comment,:text
    add_column :sras,:other_compliance,:string
  end

  def self.down
  end
end
