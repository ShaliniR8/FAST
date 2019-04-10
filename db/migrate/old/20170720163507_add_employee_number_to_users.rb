class AddEmployeeNumberToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :employee_number, :string
  end

  def self.down
    remove_column :users, :employee_number
  end
end
