class FollowUp < ActiveRecord::Migration
  def self.up
    add_column :safety_plans,:follow_up,:text,:default=>""
  end

  def self.down
  end
end
