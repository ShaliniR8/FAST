class Checklist < ActiveRecord::Base

	has_many :checklist_rows, foreign_key: :checklist_id, dependent: :destroy

	belongs_to :checklist_header, foreign_key: :checklist_header_id, class_name: "ChecklistHeader"

	accepts_nested_attributes_for :checklist_rows, allow_destroy: true

end