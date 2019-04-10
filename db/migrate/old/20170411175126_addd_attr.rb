class AdddAttr < ActiveRecord::Migration
  def self.up
    add_column :causes,:attr,:string
  end

  def self.down
  end
end
