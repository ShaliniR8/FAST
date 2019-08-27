class AddMobileFetchMonthsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :mobile_fetch_months, :integer, null: false, default: 3
  end

  def self.down
    remove_column :users, :mobile_fetch_months
  end
end
