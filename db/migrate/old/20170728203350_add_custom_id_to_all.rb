class AddCustomIdToAll < ActiveRecord::Migration
  def self.up
  	add_column :records,                :custom_id, :integer
  	add_column :corrective_actions,     :custom_id, :integer
  	add_column :audits,                 :custom_id, :integer
  	add_column :checklist_items,        :custom_id, :integer
  	add_column :sms_actions,            :custom_id, :integer
  	add_column :findings,               :custom_id, :integer
  	add_column :investigations,         :custom_id, :integer
  	add_column :recommendations,        :custom_id, :integer
    add_column :submissions,            :custom_id, :integer
    add_column :inspections,            :custom_id, :integer
    add_column :evaluations,            :custom_id, :integer
    add_column :reports,                :custom_id, :integer
    add_column :meetings,               :custom_id, :integer  

    add_column :hazards,                :custom_id, :integer
    add_column :ims,                    :custom_id, :integer
    add_column :packages,               :custom_id, :integer
    add_column :risk_controls,          :custom_id, :integer
    add_column :safety_plans,           :custom_id, :integer
    add_column :sras,                   :custom_id, :integer


  end

  def self.down
    remove_column :records,                :custom_id
    remove_column :corrective_actions,     :custom_id
    remove_column :audits,                 :custom_id
    remove_column :checklist_items,        :custom_id
    remove_column :sms_actions,            :custom_id
    remove_column :findings,               :custom_id
    remove_column :investigations,         :custom_id
    remove_column :recommendations,        :custom_id
    remove_column :submissions,            :custom_id
    remove_column :inspections,            :custom_id
    remove_column :evaluations,            :custom_id
    remove_column :reports,                :custom_id
    remove_column :meetings,               :custom_id

    remove_column :hazards,                :custom_id
    remove_column :ims,                    :custom_id
    remove_column :packages,               :custom_id
    remove_column :risk_controls,          :custom_id
    remove_column :safety_plans,           :custom_id
    remove_column :sras,                   :custom_id

  end
end
