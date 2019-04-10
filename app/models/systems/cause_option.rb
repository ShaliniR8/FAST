class CauseOption < ActiveRecord::Base
	has_and_belongs_to_many(
										:cause_options, 
										:join_table => "cause_options_connections",
										:foreign_key => "cause_option_1_id",
										:association_foreign_key => "cause_option_2_id"	
									)

	has_many :root_causes,				:foreign_key => "cause_option_id",			:class_name => "RootCause",		:dependent => :destroy


	def self.get_headers
		[ 
			{:field => :id, 					:title => "ID" 							},
			{:field => :name,					:title => "Category Name" 	},
		]
	end

	def get_value
		if self.level == 0
			"self.name"
		else
			"#{self.parent.get_value} - #{self.name}"
		end
	end


	def children
		children_options = self.cause_options.select{|x| x.level > self.level}
		children_options
	end	

	def parent
		if level == 0
			self
		else
			parent_options = self.cause_options.select{|x| x.level < self.level}
			parent_options.first
		end
	end

	def root
		if level == 0
			return self
		else
			return parent.root
		end
	end

end