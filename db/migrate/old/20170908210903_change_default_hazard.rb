class ChangeDefaultHazard < ActiveRecord::Migration
  def self.up
    change_column :hazards,:status,:string,:default=>"Open"
  end

  def self.down
  end
end
