class AddMinutesToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :minutes, :text
  end

  def self.down
    remove_column :reports, :minutes
  end
end
