class UpgradeTranscations < ActiveRecord::Migration
  def self.up
    add_column :transactions,:type,:string
    rename_column :transactions,:reports_id,:owner_id
  end

  def self.down
  end
end
