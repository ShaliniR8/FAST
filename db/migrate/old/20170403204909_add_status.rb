class AddStatus < ActiveRecord::Migration
  def self.up
    remove_column :audits,:status
    add_column :audits,:status,:string
    add_column :audits,:viewer_access,:boolean,:default=>false
  end

  def self.down
    remove_column :audits,:Status
  end
end
