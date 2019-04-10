class FrameworkMeeting <SmsMeeting
	has_many :packages,foreign_key:"meeting_id",class_name:"Package"
	def self.package_type
		'FrameworkImPackage'
	end
end