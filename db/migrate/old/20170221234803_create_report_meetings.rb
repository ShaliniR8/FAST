class CreateReportMeetings < ActiveRecord::Migration
  def self.up
    create_table :report_meetings do |t|
      t.integer :report_id
      t.integer :meeting_id
      t.timestamps
    end
  end

  def self.down
    drop_table :report_meetings
  end
end
