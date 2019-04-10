class AddPocIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :poc_id, :integer
  end

  def self.down
    remove_column :users, :poc_id
  end
end
