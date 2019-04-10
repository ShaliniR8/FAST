class PackageTransaction < Transaction
  belongs_to :package, foreign_key: "owner_id",class_name:"Package"
end
