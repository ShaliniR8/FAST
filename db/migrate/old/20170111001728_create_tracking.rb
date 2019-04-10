class CreateTracking < ActiveRecord::Migration
  def self.up
  	create_table :trackings do |t|
  		t.string :title
  		t.string :priority
  		t.string :category
  		t.string :description
  		t.date	 :start_date
  		t.date   :due_date
  		t.timestamps
  	end
  end

  def self.down
  	drop_table :trackings
  end
end
