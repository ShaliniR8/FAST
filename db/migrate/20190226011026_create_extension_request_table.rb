class CreateExtensionRequestTable < ActiveRecord::Migration
	def self.up
		create_table "extension_requests", :force => true do |t|
			t.timestamps
			t.string 				:type
			t.integer 			:owner_id
			t.integer				:requester_id
			t.date 					:request_date
			t.integer 			:approver_id
			t.string				:detail
			t.string				:status
			t.date 					:address_date  	
			t.string				:address_comment
		end
	end

	def self.down
		drop_table :extension_requests
	end
end
