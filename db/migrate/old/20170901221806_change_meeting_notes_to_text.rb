class ChangeMeetingNotesToText < ActiveRecord::Migration
  def self.up
  	change_column :meetings, :notes, :text
  end

  def self.down
  	change_column :meetings, :notes, :string
  end
end
