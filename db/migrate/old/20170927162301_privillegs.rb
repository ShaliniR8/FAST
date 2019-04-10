class Privillegs < ActiveRecord::Migration
  def self.up
	add_column :reports,:privileges,:text
      
  end

  def self.down
  end
end
