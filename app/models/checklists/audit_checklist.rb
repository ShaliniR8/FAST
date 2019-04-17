class AuditChecklist < Checklist
	belongs_to :owner, foreign_key: :owner_id, class_name: "Audit"
end