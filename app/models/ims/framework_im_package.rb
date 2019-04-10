class FrameworkImPackage < Package
	belongs_to :item,foreign_key:"owner_id",class_name:"FrameworkImItem"
	def self.display_name
		"Framework IM Package"
	end

	def self.meeting_type
		"FrameworkMeeting"
	end
end
