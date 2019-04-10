class AddObjectIdToAudits < ActiveRecord::Migration
  def self.up
    add_column :audits, :object_id, :integer
  end

  def self.down
    remove_column :audits, :object_id
  end
end
