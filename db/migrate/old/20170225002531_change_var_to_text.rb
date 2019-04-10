class ChangeVarToText < ActiveRecord::Migration
  def self.up
    change_column :issues,:safety_issue,:text
    change_column :issues,:corrective_action,:text
  end

  def self.down
  end
end
