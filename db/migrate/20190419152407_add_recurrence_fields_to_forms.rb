class AddRecurrenceFieldsToForms < ActiveRecord::Migration
  def self.up
    add_column :audits, :template, :boolean
    add_column :audits, :recurrence_id, :integer
    add_column :evaluations, :template, :boolean
    add_column :evaluations, :recurrence_id, :integer
    add_column :investigations, :template, :boolean
    add_column :investigations, :recurrence_id, :integer
    add_column :inspections, :template, :boolean
    add_column :inspections, :recurrence_id, :integer
  end

  def self.down
    remove_column :audits, :template
    remove_column :audits, :recurrence_id
    remove_column :evaluations, :template
    remove_column :evaluations, :recurrence_id
    remove_column :investigations, :template
    remove_column :investigations, :recurrence_id
    remove_column :inspections, :template
    remove_column :inspections, :recurrence_id
  end
end
