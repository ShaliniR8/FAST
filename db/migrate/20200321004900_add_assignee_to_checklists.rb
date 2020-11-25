class AddAssigneeToChecklists < ActiveRecord::Migration
  def self.up
  	add_column :checklists, :assignee_ids, :string
  end

  def self.down
  	remove_column :checklists, :assignee_ids
  end
end
