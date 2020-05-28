class AddEventStationToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :event_station, :string
  end

  def self.down
    remove_column :reports, :event_station
  end
end
