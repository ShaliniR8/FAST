class ChangeRiskMatrixNameForReport < ActiveRecord::Migration
  def self.up
    rename_column :reports, :risk, :risk_factor
  end

  def self.down
  end
end
