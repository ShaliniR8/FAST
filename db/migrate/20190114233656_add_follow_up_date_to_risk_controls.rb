class AddFollowUpDateToRiskControls < ActiveRecord::Migration
  def self.up
    add_column :risk_controls, :follow_up_date, :date
  end

  def self.down
    remove_column :risk_controls, :follow_up_date
  end
end
