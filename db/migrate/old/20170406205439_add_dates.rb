class AddDates < ActiveRecord::Migration
  def self.up
    add_column :audits,:schedule_date,:date
    add_column :audits,:open_date,:date
    add_column :audits,:complete_date,:date
    add_column :findings,:schedule_date,:date
    add_column :findings,:open_date,:date
    add_column :findings,:complete_date,:date
  end

  def self.down
  end
end
