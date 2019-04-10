class CreateMessage < ActiveRecord::Migration
  def self.up
  	create_table :messages do |t|
  		t.string	:subject
  		t.string	:content
  		t.datetime	:due
      t.integer   :response_id
  		t.timestamp
  	end
    create_table :message_accesses do |t|
      t.belongs_to :messages
      t.belongs_to :users
      t.string     :status
      t.string     :type
      t.timestamp
    end
  end

  def self.down
  	drop_table :messages
    drop_table :message_accesses
  end
end
