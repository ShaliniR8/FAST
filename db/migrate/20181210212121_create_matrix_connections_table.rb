class CreateMatrixConnectionsTable < ActiveRecord::Migration
	def self.up
		create_table "matrix_connections", :force => true do |t|
			t.integer :matrix_id
			t.integer :owner_id
			t.string :type
		end
	end

	def self.down
		drop_table :matrix_connections
	end
end
