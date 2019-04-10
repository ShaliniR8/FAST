class ReportTransaction < Transaction
	belongs_to :report, foreign_key: "owner_id",class_name:"Report"

end
