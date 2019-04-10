class SectionField < ActiveRecord::Base
	belongs_to :field, 			:foreign_key => "field_id", 		:class_name => "Field"
	belongs_to :section,		:foreign_key => "section_id",		:class_name => "Section"
	
	has_one :category, :through => :field


	def map_field
		self.field.map_field
	end


	def display_type
		self.field.display_type
	end

	def display_size
		self.field.display_size
	end

	def data_type
		self.field.data_type
	end

	def category
		self.field.category
	end

	def print_value
		(self.display_type == "checkbox" || self.display_type == "radio")? self.value.split(";").select{|x| x.present?}.join(",  ") : self.value.gsub(/\n/, '<br/>').html_safe
	end

end
