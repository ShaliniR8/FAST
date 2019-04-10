class SecondClean < ActiveRecord::Migration
  def self.up
	drop_table :previleges
  end

  def self.down
  end
end
