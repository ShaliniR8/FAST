class Tracking < ActiveRecord::Base
	
	def self.get_priorities
		['High','Medium','Low']
	end

	def self.get_categories
		['Category 1','Category 2','Category 3']
	end

	def get_start
		if self.start_date.present?
			self.start_date.strftime "%Y-%m-%d"
		else
			""
		end
	end

	def get_due
		if self.due_date.present?
			self.due_date.strftime "%Y-%m-%d"
		else
			""
		end
	end

	def get_complete
		if self.complete_date.present?
			self.complete_date.strftime "%Y-%m-%d"
		else
			""
		end
	end


	def self.get_headers
	  [
	  	{:field=>"title" ,:size=>"col-xs-2",:title=>"Title"},
	  	{:field=>"get_start" ,:size=>"col-xs-2",:title=>"Start Date"},
	  	{:field=>"get_due" ,:size=>"col-xs-2",:title=>"Due Date"},
	  	{:field=>"priority",:size=>"col-xs-2",:title=>"Priority"},
	  	{:field=>"category" ,:size=>"col-xs-2",:title=>"Category"},
	  	{:field=>"status",:size=>"col-xs-2",:title=>"Status"}
	  ]
	end
end
