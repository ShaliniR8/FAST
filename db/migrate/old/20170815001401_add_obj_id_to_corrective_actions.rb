class AddObjIdToCorrectiveActions < ActiveRecord::Migration
  def self.up
    add_column :corrective_actions, :obj_id, :integer
  end

  def self.down
    remove_column :corrective_actions, :obj_id
  end
end
