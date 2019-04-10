class AddUser < ActiveRecord::Migration
  def self.up
    add_column :issues,:user_id,:integer
  end

  def self.down

  end
end
