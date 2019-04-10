class ChecklistItemAttachment < Attachment
	belongs_to :checklist_item, foreign_key:"owner_id", class_name: "ChecklistItem"
end
