class AddEventDateToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :event_date, :datetime
  end

  def self.down
    remove_column :reports, :event_date
  end
end
