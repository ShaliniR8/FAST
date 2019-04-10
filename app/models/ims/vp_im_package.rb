class VpImPackage < Package
	belongs_to :item,foreign_key:"owner_id",class_name:"VpImItem"

	def self.display_name
		"VP/Part 5 IM Package"
	end

	def self.meeting_type
		'VpMeeting'
	end
end
