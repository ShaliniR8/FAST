class RenameFinding < ActiveRecord::Migration
  def self.up
    rename_column :findings,:policy_vilation,:policy_violation
  end

  def self.down
  end
end
