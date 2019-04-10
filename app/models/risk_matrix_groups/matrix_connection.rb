class MatrixConnection < ActiveRecord::Base
	belongs_to :matrix_group,		:foreign_key => "matrix_id", :class_name => "RiskMatrixGroup"
end