class AuditTransaction < Transaction
  belongs_to :audit, foreign_key: "owner_id",class_name:"Audit"
end
