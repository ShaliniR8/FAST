class AddPrivileges < ActiveRecord::Migration
  def self.up
    
    add_column :corrective_actions,:privileges,:text
  end

  def self.down
    remove_column :meetings,:privileges
    remove_column :corrective_actions,:privileges
  end
end
