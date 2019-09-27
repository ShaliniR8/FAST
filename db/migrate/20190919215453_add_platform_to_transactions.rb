class AddPlatformToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :platform, :integer, :limit => 1, :default => 0
  end

  def self.down
    remove_column :transactions, :platform
  end
end
