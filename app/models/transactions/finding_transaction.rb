class FindingTransaction < Transaction
	belongs_to :finding, foreign_key: "owner_id",class_name:"Finding"
end
