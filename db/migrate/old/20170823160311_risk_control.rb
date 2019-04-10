class RiskControl < ActiveRecord::Migration
  def self.up
    add_column :risk_controls,:date_open,:date
  end

  def self.down
    remove_column :risk_controls,:date_open
  end
end
