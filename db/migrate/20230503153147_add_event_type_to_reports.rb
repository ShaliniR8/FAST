class AddEventTypeToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :event_type, :string
  end

  def self.down
    remove_column :reports, :event_type
  end
end
