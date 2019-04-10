class CreateResponsibleUsersTable < ActiveRecord::Migration
  

  def self.up
  	create_table "responsible_users", :force => true do |t|
  		t.integer		:owner_id
  		t.string		:type
  		t.integer		:user_id
  		t.string		:status
  		t.text			:comments
  		t.text			:instructions
  		t.timestamps
  	end
  end

  def self.down
  	drop_table :responsible_users
  end


end
