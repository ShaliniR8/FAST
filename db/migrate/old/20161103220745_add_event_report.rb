class AddEventReport < ActiveRecord::Migration
  def self.up
  	create_table :reports do |t|
  		t.string		:name
  		t.string		:status
  		t.string		:description
  		t.timestamp			
  	end

  	create_table :attachments do |t|
  		t.string		:type
  		t.string		:name
    	t.string		:caption
    	t.string		:owner_type
  		t.integer		:owner_id    
  		t.timestamp			
  	end

  	change_table :records do |t|
      t.belongs_to  :reports
    end
  end

  def self.down
    drop_table :reports
    drop_table :attachments
    remove_column :records,:reports_id
  end
end
