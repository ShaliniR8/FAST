class CreateOrmProcessTables < ActiveRecord::Migration
  def self.up

  	create_table "orm_templates", :force => true do |t|
  		t.string 			:name
 			t.integer 		:created_by
 			t.text				:description
 			t.timestamps
  	end

  	create_table "orm_fields", :force => true do |t| 
  		t.string			:name
  		t.string			:low
      t.integer     :low_pt
      t.string      :moderate
      t.integer     :moderate_pt
      t.string      :high
      t.string      :high_pt
  		t.integer			:orm_template_id
  		t.timestamps
  	end

  	create_table "orm_submissions", :force => true do |t|
  		t.string			:tail_number
  		t.integer			:user_id
  		t.integer			:total_score
  		t.integer			:orm_template_id
  		t.timestamps
  	end

  	create_table "orm_submission_fields", :force => true do |t| 
  		t.integer			:orm_submission_id
  		t.integer			:orm_field_id
      t.string      :selected
  	end

  end

  def self.down
  	drop_table :orm_templates
  	drop_table :orm_fields
  	drop_table :orm_submissions
  	drop_table :orm_submission_fields
  end


end
