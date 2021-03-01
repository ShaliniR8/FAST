class Sabre < ActiveRecord::Base
  before_save :check_duplicate_entry

  def check_duplicate_entry
    sabre_record = Sabre.where({flight_date: flight_date, employee_number: employee_number, flight_number: flight_number,
                                tail_number: tail_number, employee_title: employee_title, departure_airport: departure_airport,
                                arrival_airport: arrival_airport, landing_airport: landing_airport, other_employees: other_employees})
    return !sabre_record.present?
  end
end
