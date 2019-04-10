class CreateVerificationTable < ActiveRecord::Migration
	def self.up
		create_table "verifications", :force => true do |t|
			t.timestamps
			t.string 				:type
			t.integer 			:owner_id
			t.string				:users_id
			t.string				:detail
			t.string				:status
			t.date 					:verify_date  	
			t.date					:address_date
			t.string				:address_comment
		end
	end

	def self.down
		drop_table :verifications
	end
end
