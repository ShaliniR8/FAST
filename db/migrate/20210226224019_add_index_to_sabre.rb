class AddIndexToSabre < ActiveRecord::Migration
  def self.up
    add_index :sabres, :flight_date
    add_index :sabres, :employee_number
    add_index :sabres, :flight_number
    add_index :sabres, :tail_number
    add_index :sabres, :employee_title
  end

  def self.down
    remove_index :sabres, :flight_date
    remove_index :sabres, :employee_number
    remove_index :sabres, :flight_number
    remove_index :sabres, :tail_number
    remove_index :sabres, :employee_title
  end
end
