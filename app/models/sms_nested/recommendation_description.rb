class RecommendationDescription < Cause
	belongs_to :recommendation,foreign_key:"owner_id",class_name:"Recommendation"

	def self.get_headers
		[
			{:title=>"Category",:field=>"category"},
			{:title=>"Attribute",:field=>"get_attr"},
			{:title=>"Value",:field=>"get_value"}
		]
	end
	
	def get_value
		if self.value=="true"
			"Yes"
		else
			self.value
		end
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
