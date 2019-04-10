class CreateAutomatedNotifications < ActiveRecord::Migration
  def self.up
		create_table "automated_notifications", :force => true do |t|
			t.timestamps
			t.integer				:created_by
			t.string 				:object_type
			t.string				:anchor_date_field
			t.string				:audience_field
			t.string				:anchor_status
			t.integer				:interval
			t.string				:subject
			t.text					:content
		end
  end

  def self.down
  	drop_table :automated_notifications
  end
end
