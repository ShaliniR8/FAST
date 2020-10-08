class AddDepartmentsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :departments, :text
  end

  def self.down
    remove_column :users, :departments
  end
end
