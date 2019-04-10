class AddMoreTimestamps < ActiveRecord::Migration
  def self.up
    add_column :recommendations,:open_date,:date
    add_column :recommendations,:complete_date,:date
  end

  def self.down
  end
end
