class AddDesignee < ActiveRecord::Migration
  def self.up
    add_column :corrective_actions,:designee,:string
  end

  def self.down
    remove_column :corrective_actions,:designee
  end
end
