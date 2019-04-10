class AddEventTimeZoneToRecords < ActiveRecord::Migration
  def self.up
    add_column :records, :event_time_zone, :string
  end

  def self.down
  end
end
