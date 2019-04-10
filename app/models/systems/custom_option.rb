class CustomOption < ActiveRecord::Base



	def self.get_headers
		[
			{:title => "Title",					:field => :title},
			{:title => "Description",		:field => :description}
		]
	end


end