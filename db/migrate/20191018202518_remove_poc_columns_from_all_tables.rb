class RemovePocColumnsFromAllTables < ActiveRecord::Migration
  def self.up
    remove_column :agendas,            :user_poc_id
    remove_column :audits,             :auditor_poc_id
    remove_column :audits,             :approver_poc_id
    remove_column :corrective_actions, :user_poc_id
    remove_column :evaluations,        :approver_poc_id
    remove_column :evaluations,        :evaluator_poc_id
    remove_column :findings,           :responsible_user_poc_id
    remove_column :findings,           :approver_poc_id
    remove_column :ims,                :lead_evaluator_poc_id
    remove_column :ims,                :pre_reviewer_poc_id
    remove_column :inspections,        :approver_poc_id
    remove_column :investigations,     :approver_poc_id
    remove_column :investigations,     :investigator_poc_id
    remove_column :message_accesses,   :user_poc_id
    remove_column :participations,     :poc_id
    remove_column :recommendations,    :user_poc_id
    remove_column :sms_actions,        :user_poc_id
    remove_column :sms_actions,        :approver_poc_id
    remove_column :transactions,       :user_poc_id
    remove_column :transactions,       :poc_first_name
    remove_column :transactions,       :poc_last_name
    remove_column :users,              :poc_id
  end

  def self.down
    add_column    :agendas,            :user_poc_id,             :integer
    add_column    :audits,             :auditor_poc_id,          :integer
    add_column    :audits,             :approver_poc_id,         :integer
    add_column    :corrective_actions, :user_poc_id,             :integer
    add_column    :evaluations,        :approver_poc_id,         :integer
    add_column    :evaluations,        :evaluator_poc_id,        :integer
    add_column    :findings,           :responsible_user_poc_id, :integer
    add_column    :findings,           :approver_poc_id,         :integer
    add_column    :ims,                :lead_evaluator_poc_id,   :integer
    add_column    :ims,                :pre_reviewer_poc_id,     :integer
    add_column    :inspections,        :approver_poc_id,         :integer
    add_column    :investigations,     :approver_poc_id,         :integer
    add_column    :investigations,     :investigator_poc_id,     :integer
    add_column    :message_accesses,   :user_poc_id,             :integer
    add_column    :participations,     :poc_id,                  :integer
    add_column    :recommendations,    :user_poc_id,             :integer
    add_column    :sms_actions,        :user_poc_id,             :integer
    add_column    :sms_actions,        :approver_poc_id,         :integer
    add_column    :transactions,       :user_poc_id,             :integer
    add_column    :transactions,       :poc_first_name,          :string
    add_column    :transactions,       :poc_last_name,           :string
    add_column    :users,              :poc_id,                  :integer
  end
end
