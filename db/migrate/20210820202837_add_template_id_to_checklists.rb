class AddTemplateIdToChecklists < ActiveRecord::Migration
  def self.up
    add_column :checklists, :template_id, :integer
  end

  def self.down
    remove_column :checklists, :template_id
  end
end
