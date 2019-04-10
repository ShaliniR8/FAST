class AddUniqueIdToUsers < ActiveRecord::Migration
  def self.up
  	change_table :users do |t|
  		t.string :unique_id, :unique => true
  	end
  end

  def self.down
  	change_table :users do |t|
  		t.remove :unique_id
  	end
  end
end
