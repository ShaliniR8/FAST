class SetTemplateDefaultValue < ActiveRecord::Migration
  def self.up
    change_column :audits, :template, :boolean, :default => false
    change_column :inspections, :template, :boolean, :default => false
    change_column :evaluations, :template, :boolean, :default => false
    change_column :investigations, :template, :boolean, :default => false
    Audit.where("template is null").update_all(template: 0)
    Inspection.where("template is null").update_all(template: 0)
    Evaluation.where("template is null").update_all(template: 0)
    Investigation.where("template is null").update_all(template: 0)
  end

  def self.down
    change_column :audits, :template, :boolean
    change_column :inspections, :template, :boolean
    change_column :evaluations, :template, :boolean
    change_column :investigations, :template, :boolean
      
  end
end
