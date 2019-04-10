class AddRiskAssessmentToSras < ActiveRecord::Migration
  def self.up
    add_column :sras, :likelihood, :string
    add_column :sras, :severity, :string
    add_column :sras, :risk_factor, :string
    add_column :sras, :likelihood_after, :string
    add_column :sras, :severity_after, :string
    add_column :sras, :risk_factor_after, :string
    add_column :sras, :statement, :text
  end

  def self.down
    remove_column :sras, :likelihood
    remove_column :sras, :severity
    remove_column :sras, :risk_factor
    remove_column :sras, :likelihood_after
    remove_column :sras, :severity_after
    remove_column :sras, :risk_factor_after
    remove_column :sras, :statement
  end
end
