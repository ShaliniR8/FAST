class RecordTransaction < Transaction
  belongs_to :record, foreign_key: "owner_id",class_name:"Record"
end
