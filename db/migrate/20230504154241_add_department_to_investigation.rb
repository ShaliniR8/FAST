class AddDepartmentToInvestigation < ActiveRecord::Migration
  def self.up
    add_column :investigations, :department, :string
  end

  def self.down
    remove_column :investigations, :department
  end
end
