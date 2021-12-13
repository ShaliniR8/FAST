class AddIndexToChecklist < ActiveRecord::Migration
  def self.up
    add_index :checklists, :title
    add_index :checklists, :owner_type
    add_index :checklists, :owner_id
    add_index :checklists, :checklist_header_id
    add_index :checklists, :template_id

    add_index :checklist_rows, :checklist_id
    add_index :checklist_rows, :row_order

    add_index :checklist_cells, :checklist_row_id
    add_index :checklist_cells, :checklist_header_item_id
    add_index :checklist_cells, :value, length: 10
    add_index :checklist_cells, :options, length: 20
    add_index :checklist_cells, :data_type
    add_index :checklist_cells, :custom_options, length: 20
  end

  def self.down
    remove_index :checklists, :title
    remove_index :checklists, :owner_type
    remove_index :checklists, :owner_id
    remove_index :checklists, :checklist_header_id
    remove_index :checklists, :template_id

    remove_index :checklist_rows, :checklist_id
    remove_index :checklist_rows, :row_order

    remove_index :checklist_cells, :checklist_row_id
    remove_index :checklist_cells, :checklist_header_item_id
    remove_index :checklist_cells, :value
    remove_index :checklist_cells, :options
    remove_index :checklist_cells, :data_type
    remove_index :checklist_cells, :custom_options
  end
end
