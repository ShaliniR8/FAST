class AddTransactions < ActiveRecord::Migration
  def self.up
  	create_table :transactions do |t|
  		t.belongs_to	:users
  		t.belongs_to	:reports
  		t.datetime		:stamp
  		t.text			:content
  		t.string		:action
  	end
  end

  def self.down
  	drop_table 	:transactions
  end
end
