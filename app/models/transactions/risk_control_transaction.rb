class RiskControlTransaction < Transaction
  belongs_to :risk_control, foreign_key: "owner_id",class_name:"RiskControl"
end
