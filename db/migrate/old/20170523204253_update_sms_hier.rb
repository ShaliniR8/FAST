class UpdateSmsHier < ActiveRecord::Migration
  def self.up
    add_column :findings,:type,:string
  end

  def self.down
  end
end
