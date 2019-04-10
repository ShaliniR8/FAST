class CreateRiskMatrixTables < ActiveRecord::Migration
  

  def self.up

  	create_table "risk_matrix_groups", :force => true do |t|
  		t.string	:name
  		t.timestamps
  	end

  	create_table "risk_matrix_tables", :force => true do |t|
  		t.string  	:name
  		t.integer  	:group_id
  		t.timestamps
  	end

  	create_table "risk_matrix_cells", :force => true do |t|
  		t.integer		:table_row
  		t.integer		:table_column
  		t.string		:value
  		t.string		:color
  		t.integer		:table_id
  		t.timestamps
  	end
  end

  def self.down
  	drop_table :risk_matrix_groups
  	drop_table :risk_matrix_tables
  	drop_table :risk_matrix_cells
  end
end
