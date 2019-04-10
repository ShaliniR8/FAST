class ChangeComplianceName < ActiveRecord::Migration
  def self.up
    rename_column :checklist_items,:compliance,:level_of_compliance
  end

  def self.down
  end
end
