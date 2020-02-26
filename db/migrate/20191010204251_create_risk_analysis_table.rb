class CreateRiskAnalysisTable < ActiveRecord::Migration
  def self.up
    create_table :risk_analyses do |t|
      t.integer :owner_id
      t.string :owner_type
      t.integer :risk_matrix_group_id
      t.string :variant
      t.string :result
      t.string :probability
      t.string :severity
      t.string :probability_breakdown
      t.string :severity_breakdown
    end
    RiskAnalysis.transaction do
      [Hazard, Record, Report, Investigation, Finding, SmsAction].each do |riskable|
        riskable.all.each do |obj|
          if obj.likelihood.present? ||
              obj.severity.present? ||
              obj.risk_factor.present?
            RiskAnalysis.create({
              owner: obj,
              variant: 'Base',
              risk_matrix_group_id: 1,
              result: obj.risk_factor,
              probability: obj.likelihood,
              severity: obj.severity,
              probability_breakdown: obj.probability_extra,
              severity_breakdown: obj.severity_extra,
            })
          end
          if obj.likelihood_after.present? ||
              obj.severity_after.present? ||
              obj.risk_factor_after.present?
            RiskAnalysis.create({
              owner: obj,
              variant: 'Mitigated',
              risk_matrix_group_id: 1,
              result: obj.risk_factor_after,
              probability: obj.likelihood_after,
              severity: obj.severity_after,
              probability_breakdown: obj.mitigated_probability,
              severity_breakdown: obj.mitigated_severity,
            })
          end
        end
      end
    end
  end

  def self.down
    drop_table :risk_analyses
  end
end
