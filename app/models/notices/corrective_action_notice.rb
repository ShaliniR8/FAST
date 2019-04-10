class CorrectiveActionNotice < Notice
	belongs_to :corrective_action, foreign_key: "owner_id",class_name:"Corrective Action"
end
