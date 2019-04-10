class AddAuditObjectIdToFindings < ActiveRecord::Migration
  def self.up
    add_column :findings, :audit_object_id, :integer
  end

  def self.down
  end
end
