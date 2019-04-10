class FixAccessControl < ActiveRecord::Migration
  def self.up

  	create_table :access_controls do |t|
  		t.boolean	:list_type
      t.string  :action
      t.string  :entry
  		t.timestamp	
  	end  

    create_table :tags do |t|
      t.belongs_to :access_controls
      t.belongs_to :users
      t.timestamp
    end

  end

  def self.down
  		drop_table :access_controls
      drop_table :tags
  end
end
