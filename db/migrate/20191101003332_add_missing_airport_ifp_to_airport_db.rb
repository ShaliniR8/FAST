class AddMissingAirportIfpToAirportDb < ActiveRecord::Migration
  def self.up
    Airport.create airport_name: 'Laughlin/Bullhead International Airport', icao: 'KIFP', iata: 'IFP'
  end

  def self.down
  end
end
