class AddMassAssign < ActiveRecord::Migration
  def self.up
  	create_table :assignments do |t|
  		t.string		:level
  		t.belongs_to	:access_controls
  		t.timestamp		
  	end  
  end

  def self.down
  	drop_table :assignments
  end
end
