class ControlCost < Cost
  belongs_to :risk_control,foreign_key:"owner_id",class_name:"RiskControl"

  def get_date
    self.cost_date.present? ? self.cost_date.strftime("%Y-%m-%d") : ""
  end
end
