class AddFinalApproverToHazards < ActiveRecord::Migration
  def self.up
    remove_column :hazards, :respnsible_user_id
    add_column :hazards, :due_date, :date
    add_column :hazards, :responsible_user_id, :integer
    add_column :hazards, :approver_id, :integer
    add_column :hazards, :final_comment, :text
  end

  def self.down
    remove_column :hazards, :due_date
    remove_column :hazards, :approver_id
    remove_column :hazards, :responsible_user_id
    remove_column :hazards, :final_comment
  end
end
