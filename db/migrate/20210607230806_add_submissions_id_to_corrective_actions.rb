class AddSubmissionsIdToCorrectiveActions < ActiveRecord::Migration
  def self.up
    add_column :corrective_actions, :submissions_id, :integer
  end

  def self.down
    remove_column :corrective_actions, :submissions_id
  end
end
