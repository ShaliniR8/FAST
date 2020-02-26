class CreateOccurrenceTables < ActiveRecord::Migration
  def self.up
    create_table :occurrences, force: true do |t|
      t.integer 'template_id'
      t.string 'owner_type'
      t.integer 'owner_id'
      t.timestamps
      t.text 'value'
    end

    create_table :occurrence_templates, force: true do |t|
      t.integer 'parent_id'
      t.string 'title'
      t.string 'format'
      t.timestamps
      t.text   'options'
    end

  end

  def self.down
    drop_table :occurrences
    drop_table :occurrence_templates
  end
end
