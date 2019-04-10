class AddStauts < ActiveRecord::Migration
  def self.up
  	add_column :hazards,:status,:string,:default=>"New"
  end

  def self.down
  end
end
