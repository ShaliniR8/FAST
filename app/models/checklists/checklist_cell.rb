# Checklists V3
class ChecklistCell < ActiveRecord::Base
  default_scope joins(:checklist_header_item).order('checklist_header_items.display_order ASC')
  belongs_to :checklist_row, foreign_key: :checklist_row_id, class_name: "ChecklistRow"
  belongs_to :checklist_header_item, foreign_key: :checklist_header_item_id, class_name: "ChecklistHeaderItem"


  def readonly?
    false
  end
end
