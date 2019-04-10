class DateComplete < ActiveRecord::Migration
  def self.up
    add_column :sras,:date_complete,:date
    add_column :risk_controls,:date_created,:date
  end

  def self.down
  end
end
