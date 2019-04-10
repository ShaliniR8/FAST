class AddAirlineToUsers < ActiveRecord::Migration
  def self.up
  	change_table :users do |t|
  		t.string :airline, limit: 3
  	end
  end

  def self.down
  	change_table :users do |t|
  		t.remove :airline
  	end
  end
end
