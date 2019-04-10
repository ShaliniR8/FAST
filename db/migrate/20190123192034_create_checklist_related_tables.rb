class CreateChecklistRelatedTables < ActiveRecord::Migration
	def self.up
		create_table "checklist_templates", :force => true do |t|
			t.timestamps
			t.string 				:name
			t.boolean 			:archive, 					:default => 0
			t.text 					:notes
			t.integer 			:created_by
		end

		create_table "checklist_questions", :force => true do |t|
			t.timestamps
			t.integer 			:owner_id
			t.string 				:number
			t.string 				:question
			t.string 				:faa_reference
			t.string 				:airline_reference
			t.boolean 			:header, 						:default => 0
			t.boolean 			:archive, 					:default => 0
		end

		create_table "checklist_records", :force => true do |t|
			t.timestamps
			t.string 				:type
			t.string 				:owner_id
			t.string 				:number
			t.string 				:question
			t.string 				:assessment
			t.string 				:faa_reference
			t.string 				:airline_reference
			t.text 					:notes
			t.boolean 			:header, 						:default => 0
		end
	end

	def self.down
		drop_table :checklist_templates
		drop_table :checklist_questions
		drop_table :checklist_records
	end
end
