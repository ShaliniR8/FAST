class AddAuditorPocIdToAudits < ActiveRecord::Migration
  def self.up
    add_column :audits, :auditor_poc_id, :integer
  end

  def self.down
    remove_column :audits, :auditor_poc_id
  end
end
