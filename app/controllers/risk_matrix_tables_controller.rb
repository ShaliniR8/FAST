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

class RiskMatrixTablesController < ApplicationController

	before_filter :login_required

	def index
	end

	def show
	end

	def new
	end

	def create
	end



	def edit
		@record = RiskMatrixTable.find(params[:id])
		respond_to do |format|
			format.js {render "risk_matrix_groups/edit_table"}
		end
	end



	def update
		@record = RiskMatrixTable.find(params[:id])
		if @record.update_attributes(params[:risk_matrix_table])
			redirect_to risk_matrix_group_path(@record.group)
		end
	end




	def destroy
	end




	def add_row
		@record = RiskMatrixTable.find(params[:id])
		@record.add_row
		redirect_to risk_matrix_group_path(@record.group)
	end




	def add_column
		@record = RiskMatrixTable.find(params[:id])
		@record.add_column
		redirect_to risk_matrix_group_path(@record.group)
	end




	def remove_row
		@record = RiskMatrixTable.find(params[:id])
		if @record.name == "severity"
			@record.group.risk_table.risk_matrix_cells.each do |x| 
				if x.table_row == params[:table_row].to_i
					x.destroy
				end
			end
		end
		@record.risk_matrix_cells.each do |x| 
			if x.table_row == params[:table_row].to_i
				x.destroy
			end
		end
		redirect_to risk_matrix_group_path(@record.group)
	end




	def remove_column
		@record = RiskMatrixTable.find(params[:id])
		if @record.name == "probability"
			@record.group.risk_table.risk_matrix_cells.each do |x| 
				if x.table_column == params[:table_column].to_i
					x.destroy
				end
			end
		end		
		@record.risk_matrix_cells.each do |x| 
			if x.table_column == params[:table_column].to_i
				x.destroy
			end
		end
		redirect_to risk_matrix_group_path(@record.group)
	end





end