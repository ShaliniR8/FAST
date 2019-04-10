class AddCannedMessagesModel < ActiveRecord::Migration
  def self.up
    create_table "canned_messages", :force => true do |t|
    	t.string 	:name
    	t.text 		:content
    	t.integer :user_id
    	t.string 	:module
    	t.string 	:report_type
    	t.timestamps
    end
  end

  def self.down
  	remove_column :canned_messages, :name
  	remove_column :canned_messages, :content
  	remove_column :canned_messages, :user_id
  	remove_column :canned_messages, :module
  	remove_column :canned_messages, :report_type
  end
end
