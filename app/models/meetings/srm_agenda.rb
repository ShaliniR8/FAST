class SrmAgenda < Agenda	
	belongs_to :meeting,foreign_key: "owner_id", class_name:"Meeting"
	belongs_to :event,foreign_key:"event_id",class_name: "Sra"
	belongs_to :user,foreign_key:"user_id",class_name:"User"

	def self.get_headers
		[
			{:title=>"Title",:field=>:title},
			{:title=>"Status",:field=>:status},
			{:title=>"User",:field=>:get_user},
			{:title=>"Created At",:field=>:get_created},
			{:title=>"Updated At",:field=>:get_updated},
			{:title=>"Discuss",:field=>:discuss},
			{:title=>"Disposition",:field=>:disposition}
		]
	end

	def disposition
		self.accepted ? "Yes" : "No"
	end

	def discuss
		self.discussion ? "Yes" : "No"
	end

	def get_created
		self.created_at.present? ?  self.created_at.strftime("%Y-%m-%d %H:%M") : ""
 	end

	def get_updated
		self.updated_at.present? ?  self.updated_at.strftime("%Y-%m-%d %H:%M") : ""
 	end

 	def get_user
 		self.user.present? ? self.user.full_name : ""
 	end

 	def self.get_status
 		['New','Completed']
 	end
end
