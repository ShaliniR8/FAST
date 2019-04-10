# Current version of Ruby (2.1.1p76) and Rails (3.0.5) defines send s.t. saving nested attributes does not work
# This method is a "monkey patch" that can fix the issue (tested for Rails 3.0.x)
# Source: https://github.com/rails/rails/issues/11026
if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR == 0 && RUBY_VERSION >= "2.0.0"
	module ActiveRecord
		module Associations
			class AssociationProxy
				def send(method, *args)
					if proxy_respond_to?(method, true)
						super
					else
						load_target
						@target.send(method, *args)
					end
				end
			end
		end
	end
end
class SectionsController < ApplicationController

	# before_filter :set_table_name,:login_required
	before_filter :set_table_name, :oauth_load # Kaushik Mahorker KM

	def set_table_name
		@table_name = "sections"
	end
	 
	
	def index
	end

	def new
		@action = "new"
		@has_template = false
		if !params[:template].blank?
			@template = Template.find(params[:template])
			@has_template = true
			@record = Section.build(@template)
			@record.section_fields.build
		else
			@templates = Template.find(:all)
			@templates.sort_by! {|x| x.name }
		end   
	end



	def destroy
	end


	def create
		@section = Object.const_get(params[:type]).new(params[:section])
		@section.save
		@section.template.fields.each do |field|
			section_field = SectionField.new(:section_id => @section.id, :field_id => field.id)
			section_field.save
		end
		if @section.save
			redirect_to section_path(@record)
		end
	end
	


	def show
		@record = Section.find(params[:id])
		@template = @record.template
	end


	
	def update 
		if params[:section][:section_fields_attributes].present?
			params[:section][:section_fields_attributes].each_value do |field|
				if field[:value].is_a?(Array)
					field[:value].delete("")
					field[:value] = field[:value].join(";")
				end
			end
		end
		@record = Section.find(params[:id])
		if @record.update_attributes(params[:section])
			redirect_to section_path(@record)
		else
			redirect_to root_url
		end    
	end



end
