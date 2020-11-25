module RiskHandling
  extend ActiveSupport::Concern
  # This set of terms follow the expectations that the including model contains baseline + mitigated Risks

  # The model must have the following columns:
  #   likelihood
  #   severity
  #   risk_factor
  #   likelihood_after
  #   severity_after
  #   risk_factor_after
  #   severity_extra
  #   probability_extra
  #   mitigated_severity
  #   mitigated_probability

  # Use the following to include these into the model:
  #  include RiskHandling

  included do

    # Base definition handlings for risk elements
    serialize :severity_extra
    serialize :probability_extra
    serialize :mitigated_severity
    serialize :mitigated_probability
    before_create :set_extra


    #Class Methods

    def self.get_likelihood
      ['A - Improbable','B - Unlikely','C - Remote','D - Probable','E - Frequent']
    end

  end

  #Object Methods

  def display_after_risk_factor
    risk_factor_after
  end


  def display_before_risk_factor
    risk_factor
  end


  def get_after_risk_color
    CONFIG::MATRIX_INFO[:risk_table_index][display_after_risk_factor]
  end


  def get_before_risk_color
    CONFIG::MATRIX_INFO[:risk_table_index][display_before_risk_factor]
  end


  def get_extra_probability
    self.probability_extra rescue []
  end


  def get_extra_severity
    self.severity_extra rescue []
  end


  def get_mitigated_probability
    self.mitigated_probability rescue []
  end


  def get_mitigated_severity
    self.mitigated_severity rescue []
  end


  def get_risk_values
    @severity_table = CONFIG::MATRIX_INFO[:severity_table]
    @probability_table = CONFIG::MATRIX_INFO[:probability_table]
    @risk_table = CONFIG::MATRIX_INFO[:risk_table]

    @severity_score = CONFIG.calculate_severity(severity_extra)
    @sub_severity_score = CONFIG.calculate_severity(mitigated_severity)
    @probability_score = CONFIG.calculate_severity(probability_extra)
    @sub_probability_score = CONFIG.calculate_severity(mitigated_probability)

    @print_severity = CONFIG.print_severity(self, @severity_score)
    @print_probability = CONFIG.print_probability(self, @probability_score)
    @print_risk = CONFIG.print_risk(@probability_score, @severity_score)

    @print_sub_severity = CONFIG.print_severity(self, @sub_severity_score)
    @print_sub_probability = CONFIG.print_probability(self, @sub_probability_score)
    @print_sub_risk = CONFIG.print_risk(@sub_probability_score, @sub_severity_score)

    {
      :severity_1       => @print_severity,
      :severity_2       => @print_sub_severity,
      :probability_1    => @print_probability,
      :probability_2    => @print_sub_probability,
      :risk_1           => @print_risk,
      :risk_2           => @print_sub_risk,
    }
  end


  def likelihood_after_index
    self.likelihood_after.to_i
  end


  def likelihood_index
    self.likelihood.to_i
  end


  def set_extra
    if self.severity_extra.blank?
      self.severity_extra = []
    end
    if self.probability_extra.blank?
      self.probability_extra = []
    end
    if self.mitigated_severity.blank?
      self.mitigated_severity = []
    end
    if self.mitigated_probability.blank?
      self.mitigated_probability = []
    end
  end

end
