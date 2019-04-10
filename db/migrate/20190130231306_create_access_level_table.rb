class CreateAccessLevelTable < ActiveRecord::Migration
  def self.up
		create_table "access_levels", :force => true do |t|
			t.timestamps
			t.string 				:report_type
			t.integer 			:level, 					:default => 0
			t.integer				:user_id
		end  	
  end

  def self.down
  	drop_table :access_levels
  end
end
