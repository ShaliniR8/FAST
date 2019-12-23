class AddArchivedToOccurrenceTemplates < ActiveRecord::Migration
  def self.up
    add_column :occurrence_templates, :archived, :boolean, default: false
    OccurrenceTemplate.create(title: 'Default', format: 'section')
  end

  def self.down
    remove_column :occurrence_templates, :archived
  end
end
