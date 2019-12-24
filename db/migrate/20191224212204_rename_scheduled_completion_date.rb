class RenameScheduledCompletionDate < ActiveRecord::Migration
  def self.up
    rename_column :audits, :completion, :due_date
    rename_column :inspections, :completion, :due_date
    rename_column :evaluations, :completion, :due_date
    rename_column :investigations, :completion, :due_date
    rename_column :findings, :completion_date, :due_date
    rename_column :sms_actions, :schedule_completion_date, :due_date
    rename_column :recommendations, :complete_date, :due_date
    rename_column :sms_tasks, :completion, :due_date
    rename_column :sras, :scheduled_completion_date, :due_date
    rename_column :risk_controls, :scheduled_completion_date, :due_date
  end

  def self.down
    rename_column :audits, :due_date, :completion
    rename_column :inspections, :due_date, :completion
    rename_column :evaluations, :due_date, :completion
    rename_column :investigations, :due_date, :completion
    rename_column :findings, :due_date, :completion_date
    rename_column :sms_actions, :due_date, :schedule_completion_date
    rename_column :recommendations, :due_date, :complete_date
    rename_column :sms_tasks, :due_date, :completion
    rename_column :sras, :due_date, :scheduled_completion_date
    rename_column :risk_controls, :due_date, :scheduled_completion_date
  end
end
