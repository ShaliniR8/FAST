class AddLabelToOccurrenceTemplates < ActiveRecord::Migration
  def self.up
    add_column :occurrence_templates, :label, :string, default: 'Category'
  end

  def self.down
    remove_column :occurrence_templates, :label
  end
end
