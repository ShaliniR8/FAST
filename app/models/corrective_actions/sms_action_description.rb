class SmsActionDescription < Cause
	belongs_to :sms_action, foreign_key: "owner_id", class_name: "SmsAction"

	def get_value
		if self.value == "true"
			"Yes"
		else
			self.value
		end
	end



	def get_attr
		Rails.logger.debug "category=#{self.category}"
		self.class.categories[self.category].each do |c|
			if c[:name] == self.send('attr')
				return c[:title].present? ? c[:title] : c[:name].titleize
			end
		end
		return ""
	end



	def self.categories
	  {
	    "Description" => [
	    	{name: "Action", type: "select", options: ["Check Ride","Coaching","Employee Counseled","Employee Training","Letter of Warning","Manual Revision","Procedure Change"]},
	    	{name: "Action(Other)", type: "text_field"}
	    ],
	    "Narrative" => [
	    	{name: "Narrative", type: "text_area"}
	    ]
	  }.sort.to_h
	end



end
