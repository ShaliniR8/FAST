class ViewerComment < ActiveRecord::Base
	belongs_to :viewer, foreign_key:"user_id",class_name:"User"
	def get_content
		self.content.gsub(/\n/, '<br/>').html_safe
	end

	def get_subnmission_time
		self.created_at.strftime("%Y-%m-%d")
	end
	
end
