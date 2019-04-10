class QueryCondition < ActiveRecord::Base
	belongs_to :statement,						:foreign_key => "query_statement_id",				:class_name => "QueryStatement"
	belongs_to :field,								:foreign_key => "field_id",									:class_name => "Field"
	belongs_to :template,							:foreign_key => "template_id",							:class_name => "Template"
	belongs_to :category,							:foreign_key => "category_id",							:class_name => "Category"

	#serialize :value

end
