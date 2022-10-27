class AddUniqCustomIdToAudits < ActiveRecord::Migration
  def self.up
    add_column :audits, :uniq_custom_id, :string
  end

  def self.down
    remove_column :audits, :uniq_custom_id
  end
end
