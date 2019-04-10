class AddTimeZoneToSubmissions < ActiveRecord::Migration
  def self.up
    add_column :submissions, :event_time_zone, :string
  end

  def self.down
    remove_column :submissions, :event_time_zone
  end
end
