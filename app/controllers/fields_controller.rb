class FieldsController < ApplicationController
	
	def index
		@fields=Field.find(:all)
	end
end
