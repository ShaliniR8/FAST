class MeetingComment < ViewerComment
	belongs_to :audit,foreign_key: "owner_id",class_name: "Meeting"
end
