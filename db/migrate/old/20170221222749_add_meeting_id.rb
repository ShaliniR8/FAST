class AddMeetingId < ActiveRecord::Migration
  def self.up
    add_column :reports,:meeting_id,:integer
  end

  def self.down
    remove_column :reports,:meeting_id
  end
end
