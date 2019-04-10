class Addrecord < ActiveRecord::Migration
  def self.up
  	change_table :records do |t|
  		t.belongs_to :users
      t.datetime   :event_date
      t.text       :description
  	end
  end

  def self.down
  	change_table :records do |t|
  		t.remove :users_id
      t.remove :event_date
      t.remove :description
  	end
  end
end
