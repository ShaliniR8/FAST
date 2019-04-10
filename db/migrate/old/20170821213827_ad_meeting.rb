class AdMeeting < ActiveRecord::Migration
  def self.up
    add_column :sras,:meeting_id,:integer
  end

  def self.down
  end
end
