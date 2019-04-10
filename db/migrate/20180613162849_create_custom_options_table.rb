class CreateCustomOptionsTable < ActiveRecord::Migration
  def self.up
  	create_table "custom_options", :force => true do |t|
  		t.string 	:title
  		t.string	:field_type
  		t.text		:options
  		t.integer :display_size
  		t.timestamps
  	end  
  end

  def self.down
  end
end
