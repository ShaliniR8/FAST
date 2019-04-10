class CreateRootCausesTable < ActiveRecord::Migration
  def self.up

  	create_table "root_causes", :force => true do |t| 
  		t.integer		:owner_id
 			t.string		:type
 			t.integer		:cause_option_id
 			t.string		:cause_option_value
 			t.integer		:user_id
  		t.timestamps
  	end

  end

  def self.down
  	drop_table :root_causes
  end
end
