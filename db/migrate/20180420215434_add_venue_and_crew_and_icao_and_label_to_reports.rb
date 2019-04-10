class AddVenueAndCrewAndIcaoAndLabelToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :venue, :string
    add_column :reports, :crew, :string
    add_column :reports, :icao, :string
    add_column :reports, :label, :string
  end

  def self.down
    remove_column :reports, :label
    remove_column :reports, :icao
    remove_column :reports, :crew
    remove_column :reports, :venue
  end
end
