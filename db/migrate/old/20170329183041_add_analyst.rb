class AddAnalyst < ActiveRecord::Migration
  def self.up
    add_column :expectations,:analyst_id,:integer
  end

  def self.down
  end
end
