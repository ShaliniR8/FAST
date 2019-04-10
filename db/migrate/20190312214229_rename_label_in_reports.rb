class RenameLabelInReports < ActiveRecord::Migration
  def self.up
    rename_column :reports, :label, :event_label
  end

  def self.down
  end
end
