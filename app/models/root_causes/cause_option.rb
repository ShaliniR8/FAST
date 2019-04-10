class CauseOption < ActiveRecord::Base
	has_and_belongs_to_many(
										:cause_options, 
										:join_table => "cause_options_connections",
										:foreign_key => "cause_option_1_id",
										:association_foreign_key => "cause_option_2_id"	
									)

	has_many :root_causes, :foreign_key => "cause_option_id", :class_name => "RootCause", :dependent => :destroy

	accepts_nested_attributes_for :cause_options, reject_if: Proc.new{|cause_option| cause_option[:name].blank?}

	def self.get_headers
		[ 
			{:field => :id, 							:title => "ID" 							},
			{:field => :name,							:title => "Root Cause Name" 	},
			{:field => :sub_cat_num, 			:title => "Number of Sub-Categories"}
		]
	end

	def sub_cat_num
		children.keep_if{|x| !x.hidden?}.length
	end

	def get_category
		get_category_helper(parent)
	end

	def get_category_helper(x)
		if x.level == 0
			""
		elsif x.level == 1
			x.name
		else
			"#{get_category_helper(x.parent)} > #{x.name}"
		end
	end

	def get_category_all
		get_category_helper(self)
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
		level == 0 ? self : parent.root
	end

	def first_parent
		level == 1 ? self : parent.first_parent
	end

	# get all parents and parents' parent
	def ancestors
		get_ancestors_helper(self)
	end

	def get_ancestors_helper(x)
		if x.level == 0
			[x]
		else
			get_ancestors_helper(x.parent) << x
		end 
	end

	# get all children and children's children
	def descendants
		descendants_arr = []
		get_descendants_helper(self, descendants_arr)
		descendants_arr
	end

	def get_descendants_helper(x, descendants_arr)
		if x.children.present?
			x.children.each do |c|
				descendants_arr << c
				get_descendants_helper(c, descendants_arr)
			end
		else
			descendants_arr << x
		end
	end

end