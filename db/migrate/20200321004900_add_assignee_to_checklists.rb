class AddAssigneeToChecklists < ActiveRecord::Migration
  def self.up
  	add_column :checklists, :assignees, :string
  end

  def self.down
  	remove_column :checklists, :assignees
  end
end
