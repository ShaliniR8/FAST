class AddMeetingTypeToMeetings < ActiveRecord::Migration
  def self.up
    add_column :meetings, :meeting_type, :string
  end

  def self.down
    remove_column :meetings, :meeting_type
  end
end
