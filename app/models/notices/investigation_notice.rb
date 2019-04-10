class InvestigationNotice < Notice
	belongs_to :investigation, foreign_key: "owner_id",class_name:"Investigation"
end
