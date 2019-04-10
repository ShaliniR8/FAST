class Adduser < ActiveRecord::Migration
  def self.up
  	change_table :templates do |t|
  		t.belongs_to :users
  	end
  end

  def self.down
  	change_table :templates do |t|
  		t.remove :users
  	end
  end
end