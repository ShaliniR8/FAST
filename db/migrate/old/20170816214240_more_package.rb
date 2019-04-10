class MorePackage < ActiveRecord::Migration
  def self.up
    add_column :packages,:meeting_id,:integer
    add_column :packages,:reviewer_id,:integer
    change_column :packages,:status,:string,:default=>"Open"
    add_column :packages,:date_complete,:date
  end

  def self.down
  end
end
