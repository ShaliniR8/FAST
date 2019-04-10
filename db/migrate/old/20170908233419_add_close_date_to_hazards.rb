class AddCloseDateToHazards < ActiveRecord::Migration
  def self.up
    add_column :hazards, :close_date, :date
  end

  def self.down
  end
end
