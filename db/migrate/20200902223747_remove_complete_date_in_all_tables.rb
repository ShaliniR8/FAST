class RemoveCompleteDateInAllTables < ActiveRecord::Migration
  def self.up
    remove_column :audits, :complete_date
    remove_column :inspections, :complete_date
    remove_column :evaluations, :complete_date
    remove_column :investigations, :complete_date
    remove_column :findings, :complete_date
    remove_column :sms_actions, :complete_date

    remove_column :sras, :date_complete
    remove_column :risk_controls, :date_complete
    rename_column :risk_controls, :date_open, :open_date
    remove_column :safety_plans, :date_complete
  end

  def self.down
    add_column :audits, :complete_date, :date
    add_column :inspections, :complete_date, :date
    add_column :evaluations, :complete_date, :date
    add_column :investigations, :complete_date, :date
    add_column :findings, :complete_date, :date
    add_column :sms_actions, :complete_date, :date

    add_column :sras, :date_complete, :date
    add_column :risk_controls, :date_complete, :date
    rename_column :risk_controls, :open_date, :date_open
    add_column :safety_plans, :date_complete, :date
  end
end
