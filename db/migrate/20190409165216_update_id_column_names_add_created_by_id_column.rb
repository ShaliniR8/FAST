class UpdateIdColumnNamesAddCreatedByIdColumn < ActiveRecord::Migration
  def self.up

    #Safety Reporting Changes
    rename_column :corrective_actions, :users_id, :responsible_user_id
    rename_column :corrective_actions, :final_approver_id, :approver_id

    #SRAs Changes
    rename_column :sras, :manager_id, :responsible_user_id

    #Safety Assurance Changes
    rename_column :audits, :auditor_id, :responsible_user_id
    rename_column :inspections, :inspector_id, :responsible_user_id
    rename_column :evaluations, :evaluator_id, :responsible_user_id
    rename_column :investigations, :investigator_id, :responsible_user_id
    rename_column :investigations, :final_approver_id, :approver_id
    rename_column :sms_actions, :user_id, :responsible_user_id
    rename_column :recommendations, :user_id, :responsible_user_id


    #Safety Reporting Additions
    add_column :corrective_actions, :created_by_id, :integer

    #SRAs Additions
    add_column :sras, :created_by_id, :integer
    add_column :risk_controls, :created_by_id, :integer
    add_column :hazards, :created_by_id, :integer
    add_column :safety_plans, :created_by_id, :integer

    #Safety Assurance Additions
    add_column :audits, :created_by_id, :integer
    add_column :inspections, :created_by_id, :integer
    add_column :evaluations, :created_by_id, :integer
    add_column :investigations, :created_by_id, :integer
    add_column :sms_actions, :created_by_id, :integer
    add_column :findings, :created_by_id, :integer
    add_column :recommendations, :created_by_id, :integer
  end

  def self.down
    
    #Safety Reporting Changes Revert
    rename_column :corrective_actions, :responsible_user_id, :users_id
    rename_column :corrective_actions, :approver_id, :final_approver_id


    #SRAs Changes Revert
    rename_column :sras, :responsible_user_id, :manager_id

    #Safety Assurance Changes  Revert
    rename_column :audits, :responsible_user_id, :auditor_id
    rename_column :inspections, :responsible_user_id, :inspector_id
    rename_column :evaluations, :responsible_user_id, :evaluator_id
    rename_column :investigations, :responsible_user_id, :investigator_id
    rename_column :investigations, :approver_id, :final_approver_id
    rename_column :sms_actions, :responsible_user_id, :user_id
    rename_column :recommendations, :responsible_user_id, :user_id


    #Safety Reporting Additions Revert
    remove_column :corrective_actions, :created_by_id, :integer

    #SRAs Additions Revert
    remove_column :sras, :created_by_id, :integer
    remove_column :risk_controls, :created_by_id, :integer
    remove_column :hazards, :created_by_id, :integer
    remove_column :safety_plans, :created_by_id, :integer

    #Safety Assurance Additions Revert
    remove_column :audits, :created_by_id, :integer
    remove_column :inspections, :created_by_id, :integer
    remove_column :evaluations, :created_by_id, :integer
    remove_column :investigations, :created_by_id, :integer
    remove_column :sms_actions, :created_by_id, :integer
    remove_column :findings, :created_by_id, :integer
    remove_column :recommendations, :created_by_id, :integer
  end
end
