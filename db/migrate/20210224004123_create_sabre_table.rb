class CreateSabreTable < ActiveRecord::Migration
  def self.up
    create_table :sabres do |t|
      t.date    :flight_date
      t.string  :employee_number
      t.string  :flight_number
      t.string  :tail_number
      t.string  :employee_title
      t.string  :departure_airport
      t.string  :arrival_airport
      t.string  :landing_airport
      t.text    :other_employees
      t.timestamps
    end
  end

  def self.down
    drop_table :sabres
  end
end
