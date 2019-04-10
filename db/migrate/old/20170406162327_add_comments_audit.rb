class AddCommentsAudit < ActiveRecord::Migration
  def self.up
    add_column :audits,:comment,:text
  end

  def self.down
  end
end
