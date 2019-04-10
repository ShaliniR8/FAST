class MakeObjIdColumnsConsistent < ActiveRecord::Migration
  def self.up
  	rename_column :recommendations,    :object_id,           :obj_id
    rename_column :findings,           :object_id,           :obj_id
    rename_column :audits,             :object_id,           :obj_id
    rename_column :investigations,     :object_id,           :obj_id
    rename_column :checklist_items,    :object_id,           :obj_id
    rename_column :reports,            :object_id,           :obj_id
  	rename_column :causes,             :object_id,           :obj_id
    rename_column :records,            :user_object_id,      :obj_id
    rename_column :submissions,        :user_object_id,      :obj_id
    rename_column :sms_actions,        :owner_object_id,     :owner_obj_id
    rename_column :recommendations,    :linked_object_id,    :owner_obj_id
    rename_column :findings,           :audit_object_id,     :audit_obj_id
    rename_column :transactions,       :owner_object_id,     :owner_obj_id
    rename_column :sms_tasks,          :owner_object_id,     :owner_obj_id
    rename_column :checklist_items,    :owner_object_id,     :owner_obj_id
  end

  def self.down
  end
end
