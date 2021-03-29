class AddDefaultValueToPrintInFields < ActiveRecord::Migration
  def self.up
    change_column :fields, :print, :boolean, :default => true
  end

  def self.down
  end
end
