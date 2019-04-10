class AddMobileNumberToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :mobile_number, :string
    add_column :users, :work_phone_number, :string
  end

  def self.down
    remove_column :users, :mobile_number
    remove_column :users, :work_phone_number
  end
end
