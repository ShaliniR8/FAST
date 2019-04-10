class ChangeRiskMatrixName < ActiveRecord::Migration
  def self.up
    rename_column :records, :risk, :risk_factor
  end

  def self.down
    rename_column :records, :risk_factor, :risk
  end
end
