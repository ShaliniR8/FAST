class SraMatrixConnection < MatrixConnection
	belongs_to :owner,		:foreign_key => "owner_id", :class_name => "Sra"
end