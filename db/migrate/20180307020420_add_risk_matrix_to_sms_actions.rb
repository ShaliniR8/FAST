class AddRiskMatrixToSmsActions < ActiveRecord::Migration
  def self.up
  	add_column :sms_actions, :severity, :string
  	add_column :sms_actions, :likelihood, :string
  	add_column :sms_actions, :risk_factor, :string
  	add_column :sms_actions, :likelihood_after, :string
  	add_column :sms_actions, :severity_after, :string
  	add_column :sms_actions, :risk_factor_after, :string
  	add_column :sms_actions, :severity_extra, :string
  	add_column :sms_actions, :probability_extra, :string
  	add_column :sms_actions, :mitigated_severity, :string
  	add_column :sms_actions, :mitigated_probability, :string
  	add_column :sms_actions, :extra_risk, :string
  	add_column :sms_actions, :mitigated_risk, :string
  	add_column :sms_actions, :statement, :text
  end

  def self.down
  	remove_column :sms_actions, :severity
  	remove_column :sms_actions, :likelihood
  	remove_column :sms_actions, :risk_factor
  	remove_column :sms_actions, :likelihood_after
  	remove_column :sms_actions, :severity_after
  	remove_column :sms_actions, :risk_factor_after
  	remove_column :sms_actions, :severity_extra
  	remove_column :sms_actions, :probability_extra
  	remove_column :sms_actions, :mitigated_severity
  	remove_column :sms_actions, :mitigated_probability
  	remove_column :sms_actions, :extra_risk
  	remove_column :sms_actions, :mitigated_risk
  	remove_column :sms_actions, :statement
  end
end
