class AddSubstitueRiskAssessmentToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :likelihood_after, :string
    add_column :reports, :severity_after, :string
    add_column :reports, :risk_factor_after, :string
  end

  def self.down
    remove_column :reports, :likelihood_after
    remove_column :reports, :severity_after
    remove_column :reports, :risk_factor
  end
end
