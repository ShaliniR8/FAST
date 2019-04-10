class DefaultOpen < ActiveRecord::Migration
  def self.up
    change_column :sras,:status,:string,:default=>"Open"
  end

  def self.down
  end
end
