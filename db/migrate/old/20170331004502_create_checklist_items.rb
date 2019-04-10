class CreateChecklistItems < ActiveRecord::Migration
  def self.up
    create_table :checklist_items do |t|
      t.string :type
      t.integer :owner_id
      t.integer :sort_id
      t.string :title
      t.string :revision_level
      t.date   :revision_date
      t.string :department
      t.text   :requirement
      t.string :reference_number
      t.text :reference
      t.text :instructions
      t.string :created_by
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :checklist_items
  end
end
