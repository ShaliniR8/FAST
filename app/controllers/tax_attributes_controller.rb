class TaxAttributesController < ApplicationController
	before_filter :set_table_name
	def set_table_name
		@table_name="tax_attributes"
	end

	def show 
		@tax_attribute=TaxAttribute.find(params[:id])
	end

	def index
		@title="Taxonomy"
		@records=TaxAttribute.find(:all).take(200)
		@headers=TaxAttribute.get_headers
	end

end