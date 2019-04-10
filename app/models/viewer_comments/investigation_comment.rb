class InvestigationComment < ViewerComment
	belongs_to :investigation,foreign_key: "owner_id",class_name: "Investigaton"

end
