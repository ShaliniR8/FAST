class RiskMatrixGroup < ActiveRecord::Base

	has_many :tables, 							:foreign_key => "group_id",	 	:class_name => "RiskMatrixTable", 	:dependent => :destroy
	has_many :matrix_connections, 	:foreign_key => "matrix_id",	:class_name => "MatrixConnection",	:dependent => :destroy

	accepts_nested_attributes_for :tables


	def self.get_headers
		[
			{ :title => "ID",			:field => :id },
			{ :title => "Name",		:field => :name },
		]
	end


	def severity_table
		tables.where(:name => "severity").first
	end


	def probability_table
		tables.where(:name => "probability").first
	end


	def risk_table
		tables.where(:name => "risk").first
	end


end