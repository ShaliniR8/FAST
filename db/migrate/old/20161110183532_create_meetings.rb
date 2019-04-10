class CreateMeetings < ActiveRecord::Migration
  def self.up

  	create_table :meetings do |t|
      t.string   :type
  		t.datetime :review_start
  		t.datetime :review_end
  		t.datetime :meeting_start
  		t.datetime :meeting_end
  		t.string   :review_timezone
  		t.string   :meeting_timezone
  		t.string   :notes
  		t.timestamp
  	end

  	create_table :participations do |t|
      t.string   :type
  		t.belongs_to :meetings
  		t.belongs_to :users
  		t.string	 :status
  		t.string	 :comment
  		t.timestamp
  	end

  	create_table :notices do |t|
  		t.belongs_to :users
  		t.string	 :content
  		t.string	 :status
  		t.datetime	 :expire_date
  		t.timestamp
  	end
  end

  def self.down
  	drop_table :meetings
  	drop_table :participations
  	drop_table :notices
  end
end
