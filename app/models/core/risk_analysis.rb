class RiskAnalysis < ProsafetBase
  belongs_to :owner, polymorphic: true
  belongs_to :risk_matrix_group

  serialize :severity_breakdown
  serialize :probability_breakdown
  before_create :set_extra


  def set_extra
    severity_breakdown = severity_breakdown || []
    probability_breakdown = probability_breakdown || []
  end

end
