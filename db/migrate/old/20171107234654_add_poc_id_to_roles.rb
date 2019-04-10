class AddPocIdToRoles < ActiveRecord::Migration
  def self.up
	add_column :roles, :poc_id, :integer
  end

  def self.down
	remove_column :roles, :poc_id
  end
end
