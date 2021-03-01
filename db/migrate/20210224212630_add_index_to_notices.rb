class AddIndexToNotices < ActiveRecord::Migration
  def self.up
    add_index :notices, [:users_id, :status]
  end

  def self.down
    remove_index :notices, [:users_id, :status]
  end
end
