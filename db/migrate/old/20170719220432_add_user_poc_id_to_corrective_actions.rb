class AddUserPocIdToCorrectiveActions < ActiveRecord::Migration
  def self.up
    add_column :corrective_actions, :user_poc_id, :integer
  end

  def self.down
    remove_column :corrective_actions, :user_poc_id
  end
end
