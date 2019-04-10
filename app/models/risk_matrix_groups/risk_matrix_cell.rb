class RiskMatrixCell < ActiveRecord::Base

	belongs_to :table, :foreign_key => "table_id",		:class_name => "RiskMatrixTable"

end