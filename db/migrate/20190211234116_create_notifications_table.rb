class CreateNotificationsTable < ActiveRecord::Migration
  def self.up
		create_table "notifications", :force => true do |t|
			t.timestamps
			t.string 				:type
			t.integer 			:owner_id
			t.string				:users_id
			t.string				:message
			t.date					:notify_date  	
		end
  end

  def self.down
  	drop_table :notifications
  end
end
