class ChecklistRow < ActiveRecord::Base

  has_many :checklist_cells, foreign_key: :checklist_row_id, dependent: :destroy

  belongs_to :checklist, foreign_key: :checklist_id, class_name: "Checklist"

  accepts_nested_attributes_for :checklist_cells

  def get_cells
    checklist_cells.includes(:checklist_header_item).order("checklist_header_items.display_order")
  end

end
