class CreateSectionsRelatedTables < ActiveRecord::Migration
  

  def self.up
  	create_table "sections", :force => true do |t|
  		t.string 	:type
  		t.integer	:owner_id
  		t.integer :template_id
      t.string  :status
  		t.string 	:title
  		t.integer :assignee_id
  		t.integer :approver_id
  		t.text		:notes
      t.timestamps
  	end

  	create_table "section_fields", :force => true do |t| 
  		t.string 		:value
  		t.integer 	:section_id
  		t.integer 	:field_id
  	end

  end

  def self.down
  	drop_table :sections
  	drop_table :section_fields
  end
end
