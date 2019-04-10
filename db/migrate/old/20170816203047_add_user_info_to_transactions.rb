class AddUserInfoToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :poc_first_name, :string
    add_column :transactions, :poc_last_name, :string
  end

  def self.down
    remove_column :transactions, :poc_first_name
    remove_column :transactions, :poc_last_name
  end
end
