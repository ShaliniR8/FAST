class UpgradeNotices < ActiveRecord::Migration
  def self.up
    add_column :notices,:type,:string
    add_column :notices,:owner_id,:integer
  end

  def self.down
    remove_column :notices,:type
    remove_column :notices,:owner_id
  end
end
