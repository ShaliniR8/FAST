class ImNotice < Notice
	belongs_to :im, foreign_key: "owner_id",class_name:"Im"
end
