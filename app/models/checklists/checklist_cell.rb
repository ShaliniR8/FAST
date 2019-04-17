class ChecklistCell < ActiveRecord::Base

	belongs_to :checklist_row, foreign_key: :checklist_row_id, class_name: "ChecklistRow"
	belongs_to :checklist_header_item, foreign_key: :checklist_header_item_id, class_name: "ChecklistHeaderItem"

end