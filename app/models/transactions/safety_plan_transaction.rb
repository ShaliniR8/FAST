class SafetyPlanTransaction < Transaction
  belongs_to :safety_plan, foreign_key: "owner_id",class_name:"SafetyPlan"
end
