class AddDefaultValueToShowLabelInFields < ActiveRecord::Migration
  def self.up
    change_column :fields, :show_label, :boolean, :default => true
  end

  def self.down
  end
end
