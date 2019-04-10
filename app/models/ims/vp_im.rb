class VpIm < Im
	has_many :items,foreign_key:"owner_id",class_name:"VpImItem",:dependent=>:destroy
	def self.display_name
		"SMS VP/Part 5 IM"
	end
end

 