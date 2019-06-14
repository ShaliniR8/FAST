class CreateConfigurationChecklistRelatedTables < ActiveRecord::Migration
  def self.up

    create_table "checklist_headers", :force => true do |t|
      t.string      :title
      t.string      :description
      t.string      :status
      t.integer     :created_by_id
      t.timestamps
    end

    create_table "checklist_header_items", :force => true do |t|
      t.integer       :display_order
      t.integer       :checklist_header_id
      t.string        :title
      t.string        :data_type
      t.text          :options
      t.boolean       :editable, :default => false
      t.timestamps
    end

    create_table "checklists", :force => true do |t|
      t.string      :title
      t.string      :owner_type
      t.integer     :owner_id
      t.integer     :created_by_id
      t.integer     :checklist_header_id
      t.timestamps
    end

    create_table "checklist_rows", :force => true do |t|
      t.integer     :checklist_id
      t.integer     :created_by_id
      t.boolean     :is_header, :default => false
      t.timestamps
    end

    create_table "checklist_cells", :force => true do |t|
      t.integer       :checklist_row_id
      t.integer       :checklist_header_item_id
      t.string        :value
      t.timestamps
    end

  end

  def self.down
    drop_table :checklist_headers
    drop_table :checklist_header_items
    drop_table :checklists
    drop_table :checklist_rows
    drop_table :checklist_cells
  end
end
