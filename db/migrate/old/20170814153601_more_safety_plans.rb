class MoreSafetyPlans < ActiveRecord::Migration
  def self.up
    add_column :safety_plans,:monitor_interval,:integer
    add_column :safety_plans,:evaluation_items,:text
    add_column :safety_plans,:date_started,:date
    add_column :safety_plans,:date_completed,:date
    add_column :safety_plans,:result,:string
    add_column :safety_plans,:risk_factor_after,:string
  end

  def self.down
  end
end
